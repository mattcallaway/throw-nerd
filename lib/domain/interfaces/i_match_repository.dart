import '../game_match.dart';
import '../scoring/models.dart';
import '../stats.dart';

abstract class IMatchRepository {
  Future<void> createMatch(GameMatch match);
  Future<void> updateMatchStatus(String matchId, {DateTime? finishedAt, String? winnerId, bool? isCanceled});
  Future<GameMatch?> getMatch(String id);
  Future<List<GameMatch>> getRecentMatches({int limit = 10});
  Future<List<GameMatch>> getMatchesForPlayer(String playerId, {int limit = 20});
  Future<List<GameMatch>> getHeadToHeadMatches(String player1Id, String player2Id, {int limit = 20});
  
  // Sync
  Future<void> setMatchLeagueSyncStatus(String matchId, String leagueId, String source, String? remoteId);
  Future<bool> existsByRemoteId(String remoteId);

  // Basic filtering for History
  Stream<List<GameMatch>> watchMatches({GameType? type, String? locationId, String? leagueId, int limit = 50});
  
  // Stats
  Future<PlayerStats> getPlayerStats(String playerId);
  Future<GlobalStats> getGlobalStats();

  Future<void> saveTurn(String matchId, Turn turn, int legIndex, int setIndex, int roundIndex, {int? startingScore});
  Future<List<Turn>> getTurnsForMatch(String matchId);
  Future<void> deleteLastTurn(String matchId);
  Future<void> deleteMatch(String matchId);
}
