import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darts_app/domain/league/league_sync_provider.dart';
import 'package:darts_app/domain/league/league_file_models.dart';
import 'package:darts_app/services/auth/auth_service_firebase.dart';

class FirebaseLeagueProvider implements LeagueSyncProvider {
  FirebaseFirestore get _fs => FirebaseFirestore.instance;
  final FirebaseAuthProvider _auth = FirebaseAuthProvider();
  
  @override
  String get providerId => 'firebase';

  @override
  Future<void> ensureAuth() async {
     await _auth.signIn();
  }

  @override
  Future<LeagueRemoteRef> createLeague({required String name, required String creatorId}) async {
    final doc = _fs.collection('leagues').doc();
    await doc.set({
      'name': name,
      'createdBy': creatorId,
      'createdAt': FieldValue.serverTimestamp(),
      'members': {creatorId: {'role': 'admin', 'joinedAt': FieldValue.serverTimestamp()}},
      'provider': 'firebase',
    });
    
    return LeagueRemoteRef(
      remoteRoot: doc.id,
      providerId: 'firebase',
      inviteCode: doc.id, // Simple ID as invite
    );
  }

  @override
  Future<LeagueJoinResult> joinLeague({required String inviteCodeOrLink}) async {
     // Invite code is the ID for Firebase
     final docSnap = await _fs.collection('leagues').doc(inviteCodeOrLink).get();
     if (!docSnap.exists) throw Exception('League not found');
     
     final data = docSnap.data()!;
     return LeagueJoinResult(
       ref: LeagueRemoteRef(remoteRoot: docSnap.id, providerId: 'firebase', inviteCode: docSnap.id),
       name: data['name'] ?? 'Unknown',
     );
  }

  @override
  Future<void> uploadMatch({required LeagueRemoteRef leagueRef, required MatchExport payload}) async {
     // Store as document in `leagues/{id}/matches/{matchId}`
     // We map MatchExport JSON to Firestore fields.
     
     final matchesColl = _fs.collection('leagues').doc(leagueRef.remoteRoot).collection('matches');
     
     // Check existence?
     // Payload to JSON
     final data = payload.toJson();
     // Add metadata?
     data['uploadedAt'] = FieldValue.serverTimestamp();
     
     await matchesColl.doc(payload.matchId).set(data);
  }

  @override
  Future<List<RemoteMatchDescriptor>> listMatches({required LeagueRemoteRef leagueRef, DateTime? since}) async {
     // Query collection
     var query = _fs.collection('leagues').doc(leagueRef.remoteRoot).collection('matches').orderBy('completedAt');
     
     if (since != null) {
       query = query.where('completedAt', isGreaterThan: since.toIso8601String()); // Firestore timestamp handling may vary
     }
     
     final snap = await query.get();
     return snap.docs.map((d) {
        final data = d.data();
        DateTime modified = DateTime.now();
        if (data['uploadedAt'] is Timestamp) modified = (data['uploadedAt'] as Timestamp).toDate();
        
        return RemoteMatchDescriptor(
          remoteId: d.id,
          matchId: d.id,
          modifiedAt: modified,
        );
     }).toList();
  }

  @override
  Future<MatchExport> downloadMatchPayload({required LeagueRemoteRef leagueRef, required String remoteMatchId}) async {
     final doc = await _fs.collection('leagues').doc(leagueRef.remoteRoot).collection('matches').doc(remoteMatchId).get();
     if (!doc.exists) throw Exception('Match not found');
     
     return MatchExport.fromJson(doc.data()!);
  }
}
