import 'league_file_models.dart';

abstract class LeagueSyncProvider {
  /// Unique identifier for the provider (e.g. 'dropbox', 'gdrive', 'firebase')
  String get providerId;
  
  /// Authenticate the user if needed
  Future<void> ensureAuth();
  
  /// Create a new league folder/structure
  /// Returns a [LeagueRemoteRef] containing the remote path/ID
  Future<LeagueRemoteRef> createLeague({
    required String name,
    required String creatorId,
  });

  /// Join an existing league by invite code or link
  /// Returns the resolved [LeagueRemoteRef] and metadata
  Future<LeagueJoinResult> joinLeague({
    required String inviteCodeOrLink,
  });

  /// Upload a match payload (immutable)
  /// If using cloud storage, uploads JSON file.
  /// If using Firestore, writes documents.
  Future<void> uploadMatch({
    required LeagueRemoteRef leagueRef,
    required MatchExport payload,
  });

  /// List matches available remotely
  /// [since] can be used for incremental sync if supported
  Future<List<RemoteMatchDescriptor>> listMatches({
    required LeagueRemoteRef leagueRef,
    DateTime? since,
  });

  /// Download a specific match payload
  Future<MatchExport> downloadMatchPayload({
    required LeagueRemoteRef leagueRef,
    required String remoteMatchId, // Could be file path or doc ID
  });
}

class LeagueRemoteRef {
  final String remoteRoot; // Path, FolderID, or DocID
  final String providerId;
  final String? inviteCode;
  
  LeagueRemoteRef({required this.remoteRoot, required this.providerId, this.inviteCode});
}

class LeagueJoinResult {
  final LeagueRemoteRef ref;
  final String name;
  
  LeagueJoinResult({required this.ref, required this.name});
}

class RemoteMatchDescriptor {
  final String remoteId; // path or ID
  final String? matchId; // if available in metadata
  final DateTime modifiedAt;
  
  RemoteMatchDescriptor({required this.remoteId, required this.matchId, required this.modifiedAt});
}
