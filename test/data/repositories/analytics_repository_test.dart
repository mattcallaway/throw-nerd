import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:darts_app/data/local/database.dart';
import 'package:darts_app/data/repositories/analytics_repository.dart';
import 'package:darts_app/domain/scoring/models.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as d;

void main() {
  late AppDatabase db;
  late AnalyticsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AnalyticsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('getX01BasicStats calculates average Correctly', () async {
    // 1. Setup Data
    final p1 = 'p1';
    final m1 = 'm1';
    
    // Create Player
    await db.into(db.players).insert(PlayersCompanion(
       id: d.Value(p1),
       name: d.Value('Player 1'),
       color: d.Value(0xFF000000),
    )); 
    
    // Create Match
    await db.into(db.matches).insert(MatchesCompanion(
       id: d.Value(m1),
       gameType: d.Value(GameType.x01),
       settingsJson: d.Value(jsonEncode(GameConfig(type: GameType.x01).toJson())),
    ));

    // Create Turns
    // Turn 1: 60 (20, 20, 20) - 3 darts
    await db.into(db.turns).insert(TurnsCompanion(
       matchId: d.Value(m1),
       playerId: d.Value(p1),
       legIndex: d.Value(1),
       setIndex: d.Value(1),
       roundIndex: d.Value(1),
       darts: d.Value([
         const Dart(value: 20, multiplier: 1),
         const Dart(value: 20, multiplier: 1),
         const Dart(value: 20, multiplier: 1)
       ]),
       score: d.Value(60),
       dartsThrown: d.Value(3),
    ));
    
    // Turn 2: 100 (T20, 20, 20) - 3 darts
    await db.into(db.turns).insert(TurnsCompanion(
       matchId: d.Value(m1),
       playerId: d.Value(p1),
       legIndex: d.Value(1),
       setIndex: d.Value(1),
       roundIndex: d.Value(2),
       darts: d.Value([
         const Dart(value: 20, multiplier: 3),
         const Dart(value: 20, multiplier: 1),
         const Dart(value: 20, multiplier: 1)
       ]),
       score: d.Value(100),
       dartsThrown: d.Value(3),
    ));

    // 2. Execute
    final stats = await repo.getX01BasicStats(p1);

    // 3. Verify
    // Total Score: 160
    // Total Darts: 6
    // Avg3 = (160 / 6) * 3 = 80
    
    expect(stats['totalScore'], 160);
    expect(stats['totalDarts'], 6);
    expect(stats['avg3'], 80.0);
    expect(stats['highestTurn'], 100);
  });
  
  test('getFirst9Avg only considers first 3 turns (roundIndex <= 3)', () async {
    final p1 = 'p1';
    final m1 = 'm1';
    
    // Setup
    await db.into(db.players).insert(PlayersCompanion(id: d.Value(p1), name: d.Value('P1'), color: d.Value(0)));
    await db.into(db.matches).insert(MatchesCompanion(id: d.Value(m1), gameType: d.Value(GameType.x01), settingsJson: d.Value('{}')));
    
    // Turn 1 (Round 1): 100
    await db.into(db.turns).insert(TurnsCompanion(
       matchId: d.Value(m1), playerId: d.Value(p1), legIndex: d.Value(1), setIndex: d.Value(1), roundIndex: d.Value(1),
       darts: d.Value([]), score: d.Value(100), dartsThrown: d.Value(3)
    ));
    
    // Turn 2 (Round 4): 60 (Should be IGNORED for First 9)
    await db.into(db.turns).insert(TurnsCompanion(
       matchId: d.Value(m1), playerId: d.Value(p1), legIndex: d.Value(1), setIndex: d.Value(1), roundIndex: d.Value(4),
       darts: d.Value([]), score: d.Value(60), dartsThrown: d.Value(3)
    ));

    final avgF9 = await repo.getFirst9Avg(p1);
    
    // Should be 100 (100 / 3 * 3)
    // If it included Turn 2, would be (160/6)*3 = 80.
    
    expect(avgF9, 100.0);
  });
}
