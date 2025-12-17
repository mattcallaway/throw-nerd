import 'package:cloud_firestore/cloud_firestore.dart';

class League {
  final String id;
  final String name;
  final String createdBy; // UserId
  final DateTime createdAt;
  final int schemaVersion;
  
  League({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    this.schemaVersion = 1,
  });
  
  // Factory for Firestore
  factory League.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return League(
      id: doc.id,
      name: data['name'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      schemaVersion: data['schemaVersion'] ?? 1,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'schemaVersion': schemaVersion,
    };
  }
}

class LeagueMember {
  final String userId;
  final String displayName;
  final String role; // 'admin', 'member'
  final DateTime joinedAt;
  
  LeagueMember({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });
  
  factory LeagueMember.fromMap(String id, Map<String, dynamic> data) {
    return LeagueMember(
      userId: id,
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'member',
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}

class LeagueMatchMetadata {
  final String id;
  final DateTime completedAt;
  final String gameType; // enum string
  final String locationName;
  final String winnerLeaguePlayerId;
  final List<String> playerIds;
  final String uploadedBy;
  final bool hasPayload;
  
  LeagueMatchMetadata({
    required this.id,
    required this.completedAt,
    required this.gameType,
    required this.locationName,
    required this.winnerLeaguePlayerId,
    required this.playerIds,
    required this.uploadedBy,
    required this.hasPayload,
  });

  factory LeagueMatchMetadata.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeagueMatchMetadata(
      id: doc.id,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      gameType: data['gameType'] ?? '',
      locationName: data['locationName'] ?? '',
      winnerLeaguePlayerId: data['winnerLeaguePlayerId'] ?? '',
      playerIds: List<String>.from(data['playerIds'] ?? []),
      uploadedBy: data['uploadedBy'] ?? '',
      hasPayload: data['hasPayload'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedAt': Timestamp.fromDate(completedAt),
      'gameType': gameType,
      'locationName': locationName,
      'winnerLeaguePlayerId': winnerLeaguePlayerId,
      'playerIds': playerIds,
      'uploadedBy': uploadedBy,
      'hasPayload': hasPayload,
    };
  }
}
