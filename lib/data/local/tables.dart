import 'package:drift/drift.dart';
import 'converters.dart';
import '../../domain/scoring/models.dart';

class Players extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer()(); // 0xFF...
  TextColumn get avatar => text().nullable()();
  BoolColumn get isGuest => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Locations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Matches extends Table {
  TextColumn get id => text()();
  TextColumn get gameType => text().map(const GameTypeConverter())();
  TextColumn get locationId => text().nullable().references(Locations, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get winnerId => text().nullable().references(Players, #id)();
  TextColumn get settingsJson => text()(); // GameConfig json serialization
  BoolColumn get isCanceled => boolean().withDefault(const Constant(false))();
  
  // Sync Fields
  TextColumn get source => text().withDefault(const Constant('local'))(); // 'local', 'league_firebase', 'league_gdrive', 'league_dropbox'
  TextColumn get leagueId => text().nullable().references(Leagues, #id)();
  TextColumn get remoteId => text().nullable()(); // ID/Path in provider

  @override
  Set<Column> get primaryKey => {id};
}

class Leagues extends Table {
  TextColumn get id => text()(); // UUID for local ref, OR remote specific ID.
  TextColumn get name => text()();
  TextColumn get providerType => text()(); // 'firebase', 'dropbox', 'gdrive'
  TextColumn get remoteRoot => text().nullable()(); // Folder Path or ID
  TextColumn get inviteCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class MatchPlayers extends Table {
  TextColumn get matchId => text().references(Matches, #id)();
  TextColumn get playerId => text().references(Players, #id)();
  IntColumn get playerOrder => integer()(); // 0, 1, 2...

  @override
  Set<Column> get primaryKey => {matchId, playerId};
}

class Turns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get matchId => text().references(Matches, #id)();
  TextColumn get playerId => text().references(Players, #id)();
  
  IntColumn get legIndex => integer()(); // 1-based or 0-based
  IntColumn get setIndex => integer()();
  IntColumn get roundIndex => integer()(); // Turn number in the leg
  
  TextColumn get darts => text().map(const DartsConverter())();
  
  // Analytics Cache Columns
  IntColumn get score => integer().nullable()();
  IntColumn get dartsThrown => integer().nullable()();
  IntColumn get startingScore => integer().nullable()();
  
  // Snapshot stats for easy history? Maybe not needed for V1.
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
