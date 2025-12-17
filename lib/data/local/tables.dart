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
  // New columns 
  TextColumn get leagueId => text().nullable().references(Leagues, #id)(); // Null for global/local-personal
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  
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
  
  // New Fields for Formal Leagues
  TextColumn get seasonId => text().nullable().references(Seasons, #id)();
  TextColumn get scheduleMatchId => text().nullable()();
  TextColumn get stage => text().nullable()(); // regular, quarterfinal, semifinal, final
  TextColumn get uploadedBy => text().nullable()();
  TextColumn get complianceStatus => text().nullable()(); // 'valid', 'invalid', 'ignored'

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
  
  // New Fields
  TextColumn get ownerId => text().nullable()();
  TextColumn get mode => text().withDefault(const Constant('informal'))();
  TextColumn get activeSeasonId => text().nullable()();
  TextColumn get rulesJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Seasons extends Table {
  TextColumn get id => text()(); // seasonId
  TextColumn get leagueId => text().references(Leagues, #id)();
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()(); // If null, active
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class ScheduleGameDays extends Table {
  TextColumn get id => text()(); // gameDayId
  TextColumn get seasonId => text().references(Seasons, #id)();
  IntColumn get dayIndex => integer()(); // 1, 2, 3...
  DateTimeColumn get date => dateTime()();
  TextColumn get locationId => text().nullable()();
  TextColumn get notes => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class ScheduleMatches extends Table {
  TextColumn get id => text()(); // scheduleMatchId
  TextColumn get gameDayId => text().references(ScheduleGameDays, #id)();
  TextColumn get homePlayerId => text()();
  TextColumn get awayPlayerId => text()();
  TextColumn get stage => text()(); // 'regular'
  IntColumn get matchOrder => integer()();
  TextColumn get linkedMatchId => text().nullable()(); // If played, link to Matches.id
  
  @override
  Set<Column> get primaryKey => {id};
}

class MatchAnnotations extends Table {
  TextColumn get matchId => text().references(Matches, #id)();
  TextColumn get locationId => text().nullable()();
  TextColumn get notes => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {matchId};
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
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
