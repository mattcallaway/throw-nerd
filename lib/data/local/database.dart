import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'converters.dart';
import '../../domain/scoring/models.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Players, Locations, Matches, MatchPlayers, Turns, Leagues])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 5;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
       await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
       if (from < 2) {
          await m.addColumn(matches, matches.source);
          await m.addColumn(matches, matches.leagueId);
          await m.addColumn(matches, matches.remoteId);
       }
       if (from < 3) {
          await m.createTable(leagues);
       }
       if (from < 4) {
          await m.addColumn(turns, turns.score);
          await m.addColumn(turns, turns.dartsThrown);
       }
       if (from < 5) {
          await m.addColumn(turns, turns.startingScore);
       }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    // Use appDataFolder for auto-backup potentially, but Documents is standard for persistent user data.
    // User requested "Backup/Restore to Google Drive appDataFolder (preferred) OR Storage Access Framework"
    // So local file should be accessible.
    
    final file = File(p.join(dbFolder.path, 'darts_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
