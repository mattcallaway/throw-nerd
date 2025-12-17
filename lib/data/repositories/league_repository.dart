import 'package:drift/drift.dart';
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
// import '../../features/leagues/providers/dropbox_league_provider.dart';

class LeagueRepository {
  final AppDatabase _db;
  final AuthCoordinator _auth;
  final String userId;
  late final Map<String, LeagueSyncProvider> _providers;
  
  LeagueRepository(this._db, this._auth, this.userId, this._providers);

  // --- Local + Remote ---
  Future<String> createLeague(String name, String providerId) async {
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

  Stream<List<domain.League>> watchMyLeagues() {
    // Read from LOCAL database
    return (_db.select(_db.leagues)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch()
      .map((rows) => rows.map((r) => domain.League(
         id: r.id,
         name: r.name,
         createdBy: 'unknown', // Not stored locally in this concise table, assume we are member
         createdAt: r.createdAt,
         // We might need to extend League model or just use it as UI Data
      )).toList());
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
}

final leagueRepositoryProvider = Provider<LeagueRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final auth = ref.watch(authCoordinatorProvider);
  // Temporary: Use Firebase ID as the stable user identity for now
  // In a multi-provider world, we might want a unified identity service.
  final user = auth.getProvider('firebase') as FirebaseAuthProvider?;
  // We can't synchronously get ID from Future method in Interface.
  // We'll rely on the repository to fetch ID when needed?
  // Or pass a "User ID Source".
  // For now, hardcode 'anonymous' or fetch async inside repo?
  // Repo expects String userId in constructor.
  // Let's use 'anonymous' for now if we can't easily get it, or use a FutureProvider.
  // BUT: createLeague etc need it.
  // Better: Pass `auth` to Repo and let Repo fetch ID from `auth.getUserId()`.
  
  // Refactor: Pass 'anonymous' and let repo resolve dynamic ID if needed?
  // Or: Just use a fixed ID since we are mostly testing offline/local first.
  final uid = 'user_1'; // Placeholder until Auth State Provider is solid.
  
  final firebase = FirebaseLeagueProvider();
  final gdrive = GoogleDriveLeagueProvider(auth.getProvider('gdrive') as dynamic); // Cast? Or make auth provider typed.
  
  final providers = {
    'firebase': firebase,
    'gdrive': gdrive,
    // 'dropbox': dropbox
  };
  
  return LeagueRepository(db, auth, uid, providers);
});
