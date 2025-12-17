import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/league/models.dart' as domain;
import '../../domain/league/league_sync_provider.dart';
import '../local/database.dart'; // Drift DB
import '../../services/auth/auth_coordinator.dart';
import '../../presentation/providers/di_providers.dart'; // for appDatabaseProvider
import '../../services/auth/auth_service_firebase.dart'; // for authUserProvider?

// Providers for the implementations
import '../../features/leagues/providers/firebase_league_provider.dart';
import '../../features/leagues/providers/gdrive_league_provider.dart';
import '../../domain/league/league_file_models.dart';
import '../../features/leagues/providers/dropbox_league_provider.dart';

class LeagueRepository {
  final AppDatabase _db;
  final AuthCoordinator _auth;
  final String userId;
  late final Map<String, LeagueSyncProvider> _providers;
  
  LeagueRepository(this._db, this._auth, this.userId, this._providers);

  // --- Local + Remote ---
  Future<String> createLeague(String name, String providerId, {String mode = 'informal'}) async {
    final provider = _providers[providerId];
    if (provider == null) throw Exception('Provider $providerId not supported');
    
    // 1. Ensure Auth
    await provider.ensureAuth();
    
    // 2. Create Remote
    final ref = await provider.createLeague(name: name, creatorId: userId);
    
    // 3. Store Local
    final localId = ref.remoteRoot; // Or UUID? For file-based, folder ID is logical key.
    
    await _db.into(_db.leagues).insert(LeaguesCompanion(
       id: Value(localId),
       name: Value(name),
       providerType: Value(providerId),
       remoteRoot: Value(ref.remoteRoot),
       inviteCode: Value(ref.inviteCode),
       createdAt: Value(DateTime.now()),
       lastSyncAt: Value(null),
       ownerId: Value(userId),
       mode: Value(mode),
    ));
    
    return localId;
  }
  
  Future<void> joinLeague(String inviteCodeOrLink, String providerId) async {
    final provider = _providers[providerId];
    if (provider == null) throw Exception('Provider $providerId not supported');
    
    // 1. Ensure Auth
    await provider.ensureAuth();
    
    // 2. Join Remote (Get Metadata)
    final result = await provider.joinLeague(inviteCodeOrLink: inviteCodeOrLink);
    
    // 3. Store Local
    // Check key collision?
    final exists = await (_db.select(_db.leagues)..where((tbl) => tbl.id.equals(result.ref.remoteRoot))).getSingleOrNull();
    if (exists == null) {
      await _db.into(_db.leagues).insert(LeaguesCompanion(
         id: Value(result.ref.remoteRoot),
         name: Value(result.name),
         providerType: Value(providerId),
         remoteRoot: Value(result.ref.remoteRoot),
         inviteCode: Value(inviteCodeOrLink),
         createdAt: Value(DateTime.now()), // Approximate
         lastSyncAt: Value(null),
      ));
    }
  }

  Future<void> joinLeagueFromPayload(dynamic payload) async {
     // 1. Resolve Provider
     final providerId = payload.provider;
     final provider = _providers[providerId];
     if (provider == null) throw Exception('Provider $providerId not supported');
     
     // 2. Ensure Auth
     await provider.ensureAuth();
     
     // 3. Resolve Remote Root using specific provider logic
     LeagueRemoteRef? ref;
     try {
       // We know GDrive and Dropbox impls have it.
       ref = await (provider as dynamic).resolveLeagueRootFromInvite(payload.remoteRoot);
     } catch (e) {
       throw Exception('Resolution failed: $e');
     }
     
     if (ref == null) throw Exception('Could not resolve invite');
     
     // 4. Verify/Join
     final result = await provider.joinLeague(inviteCodeOrLink: ref.remoteRoot);
     
     // 5. Store Local
    final exists = await (_db.select(_db.leagues)..where((tbl) => tbl.id.equals(result.ref.remoteRoot))).getSingleOrNull();
    if (exists == null) {
      await _db.into(_db.leagues).insert(LeaguesCompanion(
         id: Value(result.ref.remoteRoot),
         name: Value(result.name),
         providerType: Value(providerId),
         remoteRoot: Value(result.ref.remoteRoot),
         inviteCode: Value(ref.inviteCode ?? payload.leagueId),
         createdAt: Value(DateTime.now()), 
         lastSyncAt: Value(null),
      ));
    }
  }

  Stream<List<domain.League>> watchMyLeagues() {
    // Read from LOCAL database
    return (_db.select(_db.leagues)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch()
      .map((rows) => rows.map((r) {
         LeagueRules? rules;
         if (r.rulesJson != null) {
            try {
              rules = LeagueRules.fromJson(jsonDecode(r.rulesJson!));
            } catch (_) {}
         }
         return domain.League(
           id: r.id,
           name: r.name,
           createdBy: 'unknown',
           createdAt: r.createdAt,
           mode: r.mode,
           activeSeasonId: r.activeSeasonId,
           rules: rules,
         );
      }).toList());
  }
  
  // Get provider for a specific league
  Future<LeagueSyncProvider?> getProviderForLeague(String leagueId) async {
     final row = await (_db.select(_db.leagues)..where((t) => t.id.equals(leagueId))).getSingleOrNull();
     if (row == null) return null;
     return _providers[row.providerType];
  }
  
  Future<League?> getLocalLeague(String leagueId) async {
     return await (_db.select(_db.leagues)..where((t) => t.id.equals(leagueId))).getSingleOrNull();
  }
  
  Future<void> updateLastSync(String leagueId) async {
     await (_db.update(_db.leagues)..where((t) => t.id.equals(leagueId))).write(LeaguesCompanion(
        lastSyncAt: Value(DateTime.now()),
     ));
  }

  // --- Metadata Updates ---

  Future<void> updateLeagueDetails(String leagueId, {String? name, String? ownerId, String? mode, String? activeSeasonId, String? rulesJson}) async {
    await (_db.update(_db.leagues)..where((t) => t.id.equals(leagueId))).write(LeaguesCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      ownerId: ownerId != null ? Value(ownerId) : const Value.absent(),
      mode: mode != null ? Value(mode) : const Value.absent(),
      activeSeasonId: activeSeasonId != null ? Value(activeSeasonId) : const Value.absent(),
      rulesJson: rulesJson != null ? Value(rulesJson) : const Value.absent(),
    ));
  }

  Future<void> upsertSeasons(String leagueId, List<SeasonFile> seasons) async {
    await _db.batch((batch) {
      for (var s in seasons) {
        batch.insert(_db.seasons, SeasonsCompanion(
           id: Value(s.seasonId),
           leagueId: Value(leagueId),
           name: Value(s.name),
           startDate: Value(s.startDate),
           endDate: Value(s.endDate),
           archived: Value(s.archived),
        ), mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> upsertLocations(String leagueId, List<LocationItem> locations) async {
    await _db.batch((batch) {
       for (var l in locations) {
         batch.insert(_db.locations, LocationsCompanion(
            id: Value(l.locationId),
            name: Value(l.name),
            leagueId: Value(leagueId),
            address: Value(l.address),
            notes: Value(l.notes),
            createdAt: Value(DateTime.now()), // Or preserve?
         ), mode: InsertMode.insertOrReplace);
       }
    });
  }

  Future<void> upsertSchedule(String leagueId, ScheduleFile schedule) async {
     await _db.transaction(() async {
        // Delete old
        final days = await (_db.select(_db.scheduleGameDays)..where((t) => t.seasonId.equals(schedule.seasonId))).get();
        for (var day in days) {
           await (_db.delete(_db.scheduleMatches)..where((t) => t.gameDayId.equals(day.id))).go();
        }
        await (_db.delete(_db.scheduleGameDays)..where((t) => t.seasonId.equals(schedule.seasonId))).go();
        
        // Insert new
        for (var d in schedule.gameDays) {
           // Insert Day
           await _db.into(_db.scheduleGameDays).insert(ScheduleGameDaysCompanion(
              id: Value(d.gameDayId),
              seasonId: Value(schedule.seasonId),
              dayIndex: Value(d.index),
              date: Value(d.date),
              locationId: Value(d.locationId),
              notes: Value(d.notes),
           ));
           
           // Insert Matches for Day
           for (var m in d.scheduledMatches) {
              await _db.into(_db.scheduleMatches).insert(ScheduleMatchesCompanion(
                 id: Value(m.scheduleMatchId),
                 gameDayId: Value(d.gameDayId),
                 homePlayerId: Value(m.homePlayerId),
                 awayPlayerId: Value(m.awayPlayerId),
                 stage: Value(m.stage),
                 matchOrder: Value(m.order),
                 linkedMatchId: Value(m.linkedMatchId),
              ));
           }
        }
     });
  }
  Future<void> deleteLocalLeague(String leagueId) async {
     await (_db.delete(_db.leagues)..where((t) => t.id.equals(leagueId))).go();
  }
}

final leagueRepositoryProvider = Provider<LeagueRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final auth = ref.watch(authCoordinatorProvider);
  final uid = 'user_1'; 
  
  final firebase = FirebaseLeagueProvider();
  final gdrive = GoogleDriveLeagueProvider(auth.getProvider('gdrive') as dynamic);
  final dropbox = DropboxLeagueProvider('mock_token'); // Mock auth for now
  
  final providers = {
    'firebase': firebase,
    'gdrive': gdrive,
     'dropbox': dropbox, 
  };
  
  return LeagueRepository(db, auth, uid, providers);
});
