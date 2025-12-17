import 'package:json_annotation/json_annotation.dart';

part 'league_file_models.g.dart';

@JsonSerializable()
class LeagueFile {
  final int schemaVersion;
  final String leagueId;
  final String name;
  final DateTime createdAt;
  final String createdBy;
  final String provider; // 'dropbox', 'gdrive'
  final String remoteRootPath;
  final int appMinVersion;
  
  // New Fields
  final String? ownerId;
  final String mode; // 'informal', 'formal'
  final DateTime? updatedAt;
  final String? updatedBy;
  final List<String> bannedMemberIds;
  final LeagueRules? rules;
  final String? activeSeasonId;

  LeagueFile({
    required this.schemaVersion,
    required this.leagueId,
    required this.name,
    required this.createdAt,
    required this.createdBy,
    required this.provider,
    required this.remoteRootPath,
    this.appMinVersion = 1,
    this.ownerId,
    this.mode = 'informal',
    this.updatedAt,
    this.updatedBy,
    this.bannedMemberIds = const [],
    this.rules,
    this.activeSeasonId,
  });
  
  factory LeagueFile.fromJson(Map<String, dynamic> json) => _$LeagueFileFromJson(json);
  Map<String, dynamic> toJson() => _$LeagueFileToJson(this);
}

@JsonSerializable()
class MatchExport {
  final String matchId;
  final DateTime completedAt;
  final String locationName;
  final String gameType;
  final String settingsJson; // Rules
  final String? winnerId;
  final List<MatchPlayerExport> players;
  final List<TurnExport> turns;
  
  MatchExport({
    required this.matchId,
    required this.completedAt,
    required this.locationName,
    required this.gameType,
    required this.settingsJson,
    this.winnerId,
    required this.players,
    required this.turns,
  });
  
  factory MatchExport.fromJson(Map<String, dynamic> json) => _$MatchExportFromJson(json);
  Map<String, dynamic> toJson() => _$MatchExportToJson(this);
}

@JsonSerializable()
class MatchPlayerExport {
  final String id; // Source ID (Local UUID)
  final String name; 
  final int order;
  
  MatchPlayerExport({required this.id, required this.name, required this.order});
  
  factory MatchPlayerExport.fromJson(Map<String, dynamic> json) => _$MatchPlayerExportFromJson(json);
  Map<String, dynamic> toJson() => _$MatchPlayerExportToJson(this);
}

@JsonSerializable()
class TurnExport {
  final String playerId;
  final int leg;
  final int set;
  final int round;
  final List<DartExport> darts;
  
  TurnExport({required this.playerId, required this.leg, required this.set, required this.round, required this.darts});
  
  factory TurnExport.fromJson(Map<String, dynamic> json) => _$TurnExportFromJson(json);
  Map<String, dynamic> toJson() => _$TurnExportToJson(this);
}

@JsonSerializable()
class DartExport {
  final int value;
  final int multiplier;
  
  DartExport({required this.value, required this.multiplier});
  
  factory DartExport.fromJson(Map<String, dynamic> json) => _$DartExportFromJson(json);
  Map<String, dynamic> toJson() => _$DartExportToJson(this);
}

// --- New Models for Formal Leagues ---

@JsonSerializable()
class LeagueRules {
  final bool requireX01;
  final List<String> allowedGameTypes; // '501', '301', 'cricket'
  final bool doubleOut;
  final int setsPerMatch;
  final int legsPerSet;
  final int gamesPerMatchup;
  final bool requireScheduleForUpload;

  LeagueRules({
    this.requireX01 = false,
    this.allowedGameTypes = const ['501', '301', 'cricket'],
    this.doubleOut = false,
    this.setsPerMatch = 1,
    this.legsPerSet = 1,
    this.gamesPerMatchup = 1,
    this.requireScheduleForUpload = false,
  });

  factory LeagueRules.fromJson(Map<String, dynamic> json) => _$LeagueRulesFromJson(json);
  Map<String, dynamic> toJson() => _$LeagueRulesToJson(this);
}

@JsonSerializable()
class SeasonFile {
  final int schemaVersion;
  final String seasonId;
  final String leagueId;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final String createdBy;
  final bool archived;

  SeasonFile({
    required this.schemaVersion,
    required this.seasonId,
    required this.leagueId,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.createdBy,
    this.archived = false,
  });

  factory SeasonFile.fromJson(Map<String, dynamic> json) => _$SeasonFileFromJson(json);
  Map<String, dynamic> toJson() => _$SeasonFileToJson(this);
}

@JsonSerializable()
class LocationFile {
  final int schemaVersion;
  final DateTime updatedAt;
  final String updatedBy;
  final List<LocationItem> locations;

  LocationFile({
    required this.schemaVersion,
    required this.updatedAt,
    required this.updatedBy,
    required this.locations,
  });

  factory LocationFile.fromJson(Map<String, dynamic> json) => _$LocationFileFromJson(json);
  Map<String, dynamic> toJson() => _$LocationFileToJson(this);
}

@JsonSerializable()
class LocationItem {
  final String locationId;
  final String name;
  final String? address;
  final String? notes;

  LocationItem({required this.locationId, required this.name, this.address, this.notes});

  factory LocationItem.fromJson(Map<String, dynamic> json) => _$LocationItemFromJson(json);
  Map<String, dynamic> toJson() => _$LocationItemToJson(this);
}

@JsonSerializable()
class ScheduleFile {
  final int schemaVersion;
  final String seasonId;
  final String leagueId;
  final DateTime updatedAt;
  final String updatedBy;
  final ScheduleFormat format;
  final List<GameDay> gameDays;
  final Playoffs? playoffs;

  ScheduleFile({
    required this.schemaVersion,
    required this.seasonId,
    required this.leagueId,
    required this.updatedAt,
    required this.updatedBy,
    required this.format,
    required this.gameDays,
    this.playoffs,
  });

  factory ScheduleFile.fromJson(Map<String, dynamic> json) => _$ScheduleFileFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleFileToJson(this);
}

@JsonSerializable()
class ScheduleFormat {
  final String type; // 'round_robin'
  final int gamesPerMatchup;
  final int setsPerMatch;
  final int legsPerSet;
  final bool doubleOut;
  final List<String> allowedGameTypes;

  ScheduleFormat({
    required this.type,
    required this.gamesPerMatchup,
    required this.setsPerMatch,
    required this.legsPerSet,
    required this.doubleOut,
    required this.allowedGameTypes,
  });

  factory ScheduleFormat.fromJson(Map<String, dynamic> json) => _$ScheduleFormatFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleFormatToJson(this);
}

@JsonSerializable()
class GameDay {
  final String gameDayId;
  final int index; // Week 1, 2...
  final DateTime date;
  final String? locationId;
  final String? notes;
  final List<ScheduledMatch> scheduledMatches;

  GameDay({
    required this.gameDayId,
    required this.index,
    required this.date,
    this.locationId,
    this.notes,
    required this.scheduledMatches,
  });

  factory GameDay.fromJson(Map<String, dynamic> json) => _$GameDayFromJson(json);
  Map<String, dynamic> toJson() => _$GameDayToJson(this);
}

@JsonSerializable()
class ScheduledMatch {
  final String scheduleMatchId;
  final String homePlayerId;
  final String awayPlayerId;
  final String stage; // 'regular', 'quarterfinal', etc.
  final int order;
  final String? linkedMatchId; // If played

  ScheduledMatch({
    required this.scheduleMatchId,
    required this.homePlayerId,
    required this.awayPlayerId,
    required this.stage,
    required this.order,
    this.linkedMatchId,
  });

  factory ScheduledMatch.fromJson(Map<String, dynamic> json) => _$ScheduledMatchFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduledMatchToJson(this);
}

@JsonSerializable()
class Playoffs {
  final bool enabled;
  final String type; // 'single_elimination'
  final int qualifiers;
  final bool includeQuarterfinals;
  final bool includeSemifinals;
  final bool includeFinal;
  final bool includeThirdPlace;
  final String seedingRule;

  Playoffs({
    this.enabled = false,
    this.type = 'single_elimination',
    this.qualifiers = 8,
    this.includeQuarterfinals = true,
    this.includeSemifinals = true,
    this.includeFinal = true,
    this.includeThirdPlace = false,
    this.seedingRule = 'standings_points_then_tiebreakers',
  });

  factory Playoffs.fromJson(Map<String, dynamic> json) => _$PlayoffsFromJson(json);
  Map<String, dynamic> toJson() => _$PlayoffsToJson(this);
}
