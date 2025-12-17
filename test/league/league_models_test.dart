import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darts_app/domain/league/models.dart';

void main() {
  group('League Model Tests', () {
    test('League model serializes to Map correctly', () {
      final now = DateTime.now();
      final league = League(
        id: 'test_id',
        name: 'Test League',
        createdBy: 'user_123',
        createdAt: now,
      );
      
      final map = league.toMap();
      
      expect(map['name'], 'Test League');
      expect(map['createdBy'], 'user_123');
      expect(map['schemaVersion'], 1);
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('LeagueMatchMetadata serializes correctly', () {
       final now = DateTime.now();
       final meta = LeagueMatchMetadata(
         id: 'match_1',
         completedAt: now,
         gameType: 'x01',
         locationName: 'Pub',
         winnerLeaguePlayerId: 'p1',
         playerIds: ['p1', 'p2'],
         uploadedBy: 'user_1',
         hasPayload: true,
       );
       
       final map = meta.toMap();
       expect(map['gameType'], 'x01');
       expect(map['playerIds'], ['p1', 'p2']);
       expect(map['hasPayload'], true);
    });
  });
}
