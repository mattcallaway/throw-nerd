import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/game_match.dart';
import '../../domain/interfaces/i_match_repository.dart';
import '../../domain/scoring/models.dart';
import '../../domain/stats.dart';
import '../local/database.dart' as db; // Alias to avoid Turn collision

class DriftMatchRepository implements IMatchRepository {
  final db.AppDatabase _db;

  DriftMatchRepository(this._db);

  @override
  Future<void> createMatch(GameMatch match) async {
    await _db.transaction(() async {
      // 1. Insert Match
      await _db.into(_db.matches).insert(db.MatchesCompanion(
        id: Value(match.id),
        gameType: Value(match.config.type),
        locationId: Value(match.locationId),
        createdAt: Value(match.createdAt),
        finishedAt: Value(match.finishedAt),
        isCanceled: Value(match.isCanceled),
        settingsJson: Value(jsonEncode(match.config.toJson())),
      ));

      // 2. Insert MatchPlayers
      for (int i = 0; i < match.playerIds.length; i++) {
        await _db.into(_db.matchPlayers).insert(db.MatchPlayersCompanion(
          matchId: Value(match.id),
          playerId: Value(match.playerIds[i]),
          playerOrder: Value(i),
        ));
      }
    });
  }

  @override
  Future<void> updateMatchStatus(String matchId, {DateTime? finishedAt, String? winnerId, bool? isCanceled}) async {
    final companion = db.MatchesCompanion(
      finishedAt: finishedAt != null ? Value(finishedAt) : const Value.absent(),
      winnerId: winnerId != null ? Value(winnerId) : const Value.absent(),
      isCanceled: isCanceled != null ? Value(isCanceled) : const Value.absent(),
    );
    await (_db.update(_db.matches)..where((t) => t.id.equals(matchId))).write(companion);
  }
  
  @override
  Future<void> setMatchLeagueSyncStatus(String matchId, String leagueId, String source, String? remoteId) async {
    final companion = db.MatchesCompanion(
      leagueId: Value(leagueId),
      source: Value(source),
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
    );
    await (_db.update(_db.matches)..where((t) => t.id.equals(matchId))).write(companion);
  }

  @override
  Future<bool> existsByRemoteId(String remoteId) async {
    final row = await (_db.select(_db.matches)..where((t) => t.remoteId.equals(remoteId))).getSingleOrNull();
    return row != null;
  }

  @override
  Future<GameMatch?> getMatch(String id) async {
    final matchRow = await (_db.select(_db.matches)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (matchRow == null) return null;

    // Get players
    final playerRows = await (_db.select(_db.matchPlayers)..where((t) => t.matchId.equals(id))).get();
    // Sort by order
    playerRows.sort((a, b) => a.playerOrder.compareTo(b.playerOrder));
    final playerIds = playerRows.map((r) => r.playerId).toList();

    return GameMatch(
      id: matchRow.id,
      config: GameConfig.fromJson(jsonDecode(matchRow.settingsJson)),
      playerIds: playerIds,
      createdAt: matchRow.createdAt,
      finishedAt: matchRow.finishedAt,
      winnerId: matchRow.winnerId,
      isCanceled: matchRow.isCanceled,
      locationId: matchRow.locationId,
    );
  }

  @override
  Future<List<GameMatch>> getRecentMatches({int limit = 10}) async {
    final query = _db.select(_db.matches)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    
    final rows = await query.get();
    
    final results = <GameMatch>[];
    for (final row in rows) {
      final playerRows = await (_db.select(_db.matchPlayers)..where((t) => t.matchId.equals(row.id))).get();
      playerRows.sort((a, b) => a.playerOrder.compareTo(b.playerOrder));
      final playerIds = playerRows.map((r) => r.playerId).toList();
      
      results.add(GameMatch(
        id: row.id,
        config: GameConfig.fromJson(jsonDecode(row.settingsJson)),
        playerIds: playerIds,
        createdAt: row.createdAt,
        finishedAt: row.finishedAt,
        winnerId: row.winnerId,
        isCanceled: row.isCanceled,
        locationId: row.locationId,
      ));
    }
    return results;
  }

  @override
  Future<List<GameMatch>> getMatchesForPlayer(String playerId, {int limit = 20}) async {
    final query = _db.select(_db.matches).join([
      innerJoin(_db.matchPlayers, _db.matchPlayers.matchId.equalsExp(_db.matches.id))
    ])
      ..where(_db.matchPlayers.playerId.equals(playerId))
      ..orderBy([OrderingTerm.desc(_db.matches.createdAt)])
      ..limit(limit);
      
    final rows = await query.get();
    
    final results = <GameMatch>[];
    for (final row in rows) {
       final matchRow = row.readTable(_db.matches);
       // Re-fetch players for this match (standard pattern, could be optimized)
       final playerRows = await (_db.select(_db.matchPlayers)..where((t) => t.matchId.equals(matchRow.id))).get();
       playerRows.sort((a, b) => a.playerOrder.compareTo(b.playerOrder));
       final playerIds = playerRows.map((r) => r.playerId).toList();
       
       results.add(GameMatch(
        id: matchRow.id,
        config: GameConfig.fromJson(jsonDecode(matchRow.settingsJson)),
        playerIds: playerIds,
        createdAt: matchRow.createdAt,
        finishedAt: matchRow.finishedAt,
        winnerId: matchRow.winnerId,
        isCanceled: matchRow.isCanceled,
        locationId: matchRow.locationId,
      ));
    }
    return results;
  }

  @override
  Future<List<GameMatch>> getHeadToHeadMatches(String player1Id, String player2Id, {int limit = 20}) async {
    // Correct way in Drift to find matches containing P1 AND P2:
    // We select Matches where ID is in (select matchId for P1) AND ID is in (select matchId for P2)

    // 1. Get MatchIDs for P1
    final p1Matches = _db.selectOnly(_db.matchPlayers)
      ..addColumns([_db.matchPlayers.matchId])
      ..where(_db.matchPlayers.playerId.equals(player1Id));
    
    // 2. Get MatchIDs for P2
    final p2Matches = _db.selectOnly(_db.matchPlayers)
      ..addColumns([_db.matchPlayers.matchId])
      ..where(_db.matchPlayers.playerId.equals(player2Id));

    // 3. Filter matches
    final query = _db.select(_db.matches)
      ..where((m) => m.id.isInQuery(p1Matches))
      ..where((m) => m.id.isInQuery(p2Matches))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);

    final rows = await query.get();
    return _mapRowsToGameMatches(rows);
  }

  @override
  Stream<List<GameMatch>> watchRecentMatches({int limit = 20}) {
     return watchMatches(limit: limit);
  }

  @override
  Stream<List<GameMatch>> watchMatches({GameType? type, String? locationId, String? leagueId, int limit = 50}) {
      final query = _db.select(_db.matches)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(limit);
        
      if (type != null) {
        query.where((t) => t.gameType.equals(type.name)); 
      }
      if (locationId != null) {
        query.where((t) => t.locationId.equals(locationId));
      }
      if (leagueId != null) {
        query.where((t) => t.leagueId.equals(leagueId));
      }

     return query.watch().asyncMap((rows) => _mapRowsToGameMatches(rows));
  }

  // Helper
  Future<List<GameMatch>> _mapRowsToGameMatches(List<dynamic> rows) async {
       final results = <GameMatch>[];
       for (final row in rows) {
          // Dynamic invocation to avoid type resolution issues with generated code
          final matchRow = row; 
          
          final playerRows = await (_db.select(_db.matchPlayers)..where((t) => t.matchId.equals(matchRow.id))).get();
          playerRows.sort((a, b) => a.playerOrder.compareTo(b.playerOrder));
          final playerIds = playerRows.map((r) => r.playerId).toList();
          
          results.add(GameMatch(
            id: matchRow.id,
            config: GameConfig.fromJson(jsonDecode(matchRow.settingsJson)),
            playerIds: playerIds,
            createdAt: matchRow.createdAt,
            finishedAt: matchRow.finishedAt,
            winnerId: matchRow.winnerId,
            isCanceled: matchRow.isCanceled,
            locationId: matchRow.locationId,
          ));
       }
       return results;
  }

  @override
  Future<void> saveTurn(String matchId, Turn turn, int legIndex, int setIndex, int roundIndex, {int? startingScore}) async {
    final totalScore = turn.darts.fold(0, (sum, dart) => sum + dart.total);
    final dartsCount = turn.darts.length;

    await _db.into(_db.turns).insert(db.TurnsCompanion(
      matchId: Value(matchId),
      playerId: Value(turn.playerId),
      legIndex: Value(legIndex),
      setIndex: Value(setIndex),
      roundIndex: Value(roundIndex),
      darts: Value(turn.darts),
      score: Value(totalScore),
      dartsThrown: Value(dartsCount),
      startingScore: startingScore != null ? Value(startingScore) : const Value.absent(),
    ));
  }

  @override
  Future<List<Turn>> getTurnsForMatch(String matchId) async {
    final rows = await (_db.select(_db.turns)
      ..where((t) => t.matchId.equals(matchId))
      ..orderBy([(t) => OrderingTerm.asc(t.id)])) // Ordering by ID assumes insertion order
      .get();
      
    // rows are List<db.Turn>
    // we map them to Domain Turn
    return rows.map((r) => Turn(
      playerId: r.playerId,
      darts: r.darts, 
    )).toList();
  }
  
  @override
  Future<void> deleteLastTurn(String matchId) async {
    // Find max ID for match
    // Simple naive approach:
    final lastRow = await (_db.select(_db.turns)
      ..where((t) => t.matchId.equals(matchId))
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1))
      .getSingleOrNull();
      
    if (lastRow != null) {
      await (_db.delete(_db.turns)..where((t) => t.id.equals(lastRow.id))).go();
    }
  }

  @override
  Future<void> deleteMatch(String matchId) async {
    await _db.transaction(() async {
      // Cascade delete: Turns -> MatchPlayers -> Match
      await (_db.delete(_db.turns)..where((t) => t.matchId.equals(matchId))).go();
      await (_db.delete(_db.matchPlayers)..where((t) => t.matchId.equals(matchId))).go();
      await (_db.delete(_db.matches)..where((t) => t.id.equals(matchId))).go();
    });
  }

  @override
  Future<PlayerStats> getPlayerStats(String playerId) async {
    // 3. Granular Counts (Naive approach: fetch all and filter in memory since we need GameType from join)
    // Efficient Drift way: Join MatchPlayers with Matches
    final playerMatches = await (_db.select(_db.matches).join([
      innerJoin(_db.matchPlayers, _db.matchPlayers.matchId.equalsExp(_db.matches.id))
    ])..where(_db.matchPlayers.playerId.equals(playerId))).get();
    
    int x01Played = 0;
    int x01Won = 0;
    int cricketPlayed = 0;
    int cricketWon = 0;
    
    for (final row in playerMatches) {
       final match = row.readTable(_db.matches);
       // Check game type (stored as enum index or string? In createMatch: gameType: Value(match.config.type))
       // Match Table definition: IntColumn get gameType => intEnum<GameType>();
       
       if (match.gameType == GameType.x01) {
         x01Played++;
         if (match.winnerId == playerId) x01Won++;
       } else if (match.gameType == GameType.cricket) {
         cricketPlayed++;
         if (match.winnerId == playerId) cricketWon++;
       }
    }
    
    return PlayerStats(
      playerId: playerId,
      matchesPlayed: playerMatches.length,
      matchesWon: x01Won + cricketWon, // derived
      legsWon: 0, 
      x01MatchesPlayed: x01Played,
      x01MatchesWon: x01Won,
      cricketMatchesPlayed: cricketPlayed,
      cricketMatchesWon: cricketWon,
    );
  }

  @override
  Future<GlobalStats> getGlobalStats() async {
    final matches = await _db.select(_db.matches).get();
    
    String? mostActiveId;
    // Helper query for aggregation
    final playerCounts = await (_db.select(_db.matchPlayers).join([])
      ..groupBy([_db.matchPlayers.playerId])
      ..addColumns([_db.matchPlayers.playerId, _db.matchPlayers.playerId.count()])
      ..orderBy([OrderingTerm.desc(_db.matchPlayers.playerId.count())])
      ..limit(1))
      .get();
      
    if (playerCounts.isNotEmpty) {
      mostActiveId = playerCounts.first.read(_db.matchPlayers.playerId);
    }

    return GlobalStats(
      totalMatches: matches.length,
      mostActivePlayerId: mostActiveId,
    );
  }
}
