import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:darts_app/data/local/database.dart';
import 'package:darts_app/domain/scoring/models.dart'; // GameType

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Schema Version is 6', () {
    expect(db.schemaVersion, 6);
  });

  test('New tables exist and are accessible', () async {
    // Create a dummy league for FK constraints
    await db.into(db.leagues).insert(LeaguesCompanion.insert(
      id: 'L1', name: 'Test League', providerType: 'test'
    ));
    
    // Test Seasons Table
    await db.into(db.seasons).insert(SeasonsCompanion.insert(
      id: 'S1', 
      leagueId: 'L1', 
      name: 'Season 1', 
      startDate: DateTime.now()
    ));
    
    final s1 = await (db.select(db.seasons)..where((t) => t.id.equals('S1'))).getSingle();
    expect(s1.name, 'Season 1');
    expect(s1.archived, false); // Default
    
    // Test ScheduleGameDays
    await db.into(db.scheduleGameDays).insert(ScheduleGameDaysCompanion.insert(
      id: 'D1', seasonId: 'S1', dayIndex: 1, date: DateTime.now()
    ));
    
    // Test ScheduleMatches
    await db.into(db.scheduleMatches).insert(ScheduleMatchesCompanion.insert(
      id: 'M1', gameDayId: 'D1', homePlayerId: 'P1', awayPlayerId: 'P2', stage: 'regular', matchOrder: 1
    ));
    
    // Test MatchAnnotations
    await db.into(db.matches).insert(MatchesCompanion.insert(
      id: 'Match1', 
      gameType: GameType.x01,
      settingsJson: '{}',
    ));
    
    await db.into(db.matchAnnotations).insert(MatchAnnotationsCompanion.insert(
      matchId: 'Match1', notes: (const Value('My Notes'))
    ));
    
    final note = await (db.select(db.matchAnnotations)..where((t) => t.matchId.equals('Match1'))).getSingle();
    expect(note.notes, 'My Notes');
  });
}
