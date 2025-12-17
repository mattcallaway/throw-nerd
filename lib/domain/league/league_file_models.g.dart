// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_file_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeagueFile _$LeagueFileFromJson(Map<String, dynamic> json) => LeagueFile(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      leagueId: json['leagueId'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      provider: json['provider'] as String,
      remoteRootPath: json['remoteRootPath'] as String,
      appMinVersion: (json['appMinVersion'] as num?)?.toInt() ?? 1,
      ownerId: json['ownerId'] as String?,
      mode: json['mode'] as String? ?? 'informal',
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
      bannedMemberIds: (json['bannedMemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rules: json['rules'] == null
          ? null
          : LeagueRules.fromJson(json['rules'] as Map<String, dynamic>),
      activeSeasonId: json['activeSeasonId'] as String?,
    );

Map<String, dynamic> _$LeagueFileToJson(LeagueFile instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'leagueId': instance.leagueId,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'provider': instance.provider,
      'remoteRootPath': instance.remoteRootPath,
      'appMinVersion': instance.appMinVersion,
      'ownerId': instance.ownerId,
      'mode': instance.mode,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'bannedMemberIds': instance.bannedMemberIds,
      'rules': instance.rules,
      'activeSeasonId': instance.activeSeasonId,
    };

MatchExport _$MatchExportFromJson(Map<String, dynamic> json) => MatchExport(
      matchId: json['matchId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      locationName: json['locationName'] as String,
      gameType: json['gameType'] as String,
      settingsJson: json['settingsJson'] as String,
      winnerId: json['winnerId'] as String?,
      players: (json['players'] as List<dynamic>)
          .map((e) => MatchPlayerExport.fromJson(e as Map<String, dynamic>))
          .toList(),
      turns: (json['turns'] as List<dynamic>)
          .map((e) => TurnExport.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MatchExportToJson(MatchExport instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'completedAt': instance.completedAt.toIso8601String(),
      'locationName': instance.locationName,
      'gameType': instance.gameType,
      'settingsJson': instance.settingsJson,
      'winnerId': instance.winnerId,
      'players': instance.players,
      'turns': instance.turns,
    };

MatchPlayerExport _$MatchPlayerExportFromJson(Map<String, dynamic> json) =>
    MatchPlayerExport(
      id: json['id'] as String,
      name: json['name'] as String,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$MatchPlayerExportToJson(MatchPlayerExport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'order': instance.order,
    };

TurnExport _$TurnExportFromJson(Map<String, dynamic> json) => TurnExport(
      playerId: json['playerId'] as String,
      leg: (json['leg'] as num).toInt(),
      set: (json['set'] as num).toInt(),
      round: (json['round'] as num).toInt(),
      darts: (json['darts'] as List<dynamic>)
          .map((e) => DartExport.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TurnExportToJson(TurnExport instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'leg': instance.leg,
      'set': instance.set,
      'round': instance.round,
      'darts': instance.darts,
    };

DartExport _$DartExportFromJson(Map<String, dynamic> json) => DartExport(
      value: (json['value'] as num).toInt(),
      multiplier: (json['multiplier'] as num).toInt(),
    );

Map<String, dynamic> _$DartExportToJson(DartExport instance) =>
    <String, dynamic>{
      'value': instance.value,
      'multiplier': instance.multiplier,
    };

LeagueRules _$LeagueRulesFromJson(Map<String, dynamic> json) => LeagueRules(
      requireX01: json['requireX01'] as bool? ?? false,
      allowedGameTypes: (json['allowedGameTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['501', '301', 'cricket'],
      doubleOut: json['doubleOut'] as bool? ?? false,
      setsPerMatch: (json['setsPerMatch'] as num?)?.toInt() ?? 1,
      legsPerSet: (json['legsPerSet'] as num?)?.toInt() ?? 1,
      gamesPerMatchup: (json['gamesPerMatchup'] as num?)?.toInt() ?? 1,
      requireScheduleForUpload:
          json['requireScheduleForUpload'] as bool? ?? false,
    );

Map<String, dynamic> _$LeagueRulesToJson(LeagueRules instance) =>
    <String, dynamic>{
      'requireX01': instance.requireX01,
      'allowedGameTypes': instance.allowedGameTypes,
      'doubleOut': instance.doubleOut,
      'setsPerMatch': instance.setsPerMatch,
      'legsPerSet': instance.legsPerSet,
      'gamesPerMatchup': instance.gamesPerMatchup,
      'requireScheduleForUpload': instance.requireScheduleForUpload,
    };

SeasonFile _$SeasonFileFromJson(Map<String, dynamic> json) => SeasonFile(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      seasonId: json['seasonId'] as String,
      leagueId: json['leagueId'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      archived: json['archived'] as bool? ?? false,
    );

Map<String, dynamic> _$SeasonFileToJson(SeasonFile instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'seasonId': instance.seasonId,
      'leagueId': instance.leagueId,
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'archived': instance.archived,
    };

LocationFile _$LocationFileFromJson(Map<String, dynamic> json) => LocationFile(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
      locations: (json['locations'] as List<dynamic>)
          .map((e) => LocationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocationFileToJson(LocationFile instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'locations': instance.locations,
    };

LocationItem _$LocationItemFromJson(Map<String, dynamic> json) => LocationItem(
      locationId: json['locationId'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$LocationItemToJson(LocationItem instance) =>
    <String, dynamic>{
      'locationId': instance.locationId,
      'name': instance.name,
      'address': instance.address,
      'notes': instance.notes,
    };

ScheduleFile _$ScheduleFileFromJson(Map<String, dynamic> json) => ScheduleFile(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      seasonId: json['seasonId'] as String,
      leagueId: json['leagueId'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
      format: ScheduleFormat.fromJson(json['format'] as Map<String, dynamic>),
      gameDays: (json['gameDays'] as List<dynamic>)
          .map((e) => GameDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      playoffs: json['playoffs'] == null
          ? null
          : Playoffs.fromJson(json['playoffs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ScheduleFileToJson(ScheduleFile instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'seasonId': instance.seasonId,
      'leagueId': instance.leagueId,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'format': instance.format,
      'gameDays': instance.gameDays,
      'playoffs': instance.playoffs,
    };

ScheduleFormat _$ScheduleFormatFromJson(Map<String, dynamic> json) =>
    ScheduleFormat(
      type: json['type'] as String,
      gamesPerMatchup: (json['gamesPerMatchup'] as num).toInt(),
      setsPerMatch: (json['setsPerMatch'] as num).toInt(),
      legsPerSet: (json['legsPerSet'] as num).toInt(),
      doubleOut: json['doubleOut'] as bool,
      allowedGameTypes: (json['allowedGameTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ScheduleFormatToJson(ScheduleFormat instance) =>
    <String, dynamic>{
      'type': instance.type,
      'gamesPerMatchup': instance.gamesPerMatchup,
      'setsPerMatch': instance.setsPerMatch,
      'legsPerSet': instance.legsPerSet,
      'doubleOut': instance.doubleOut,
      'allowedGameTypes': instance.allowedGameTypes,
    };

GameDay _$GameDayFromJson(Map<String, dynamic> json) => GameDay(
      gameDayId: json['gameDayId'] as String,
      index: (json['index'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      locationId: json['locationId'] as String?,
      notes: json['notes'] as String?,
      scheduledMatches: (json['scheduledMatches'] as List<dynamic>)
          .map((e) => ScheduledMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GameDayToJson(GameDay instance) => <String, dynamic>{
      'gameDayId': instance.gameDayId,
      'index': instance.index,
      'date': instance.date.toIso8601String(),
      'locationId': instance.locationId,
      'notes': instance.notes,
      'scheduledMatches': instance.scheduledMatches,
    };

ScheduledMatch _$ScheduledMatchFromJson(Map<String, dynamic> json) =>
    ScheduledMatch(
      scheduleMatchId: json['scheduleMatchId'] as String,
      homePlayerId: json['homePlayerId'] as String,
      awayPlayerId: json['awayPlayerId'] as String,
      stage: json['stage'] as String,
      order: (json['order'] as num).toInt(),
      linkedMatchId: json['linkedMatchId'] as String?,
    );

Map<String, dynamic> _$ScheduledMatchToJson(ScheduledMatch instance) =>
    <String, dynamic>{
      'scheduleMatchId': instance.scheduleMatchId,
      'homePlayerId': instance.homePlayerId,
      'awayPlayerId': instance.awayPlayerId,
      'stage': instance.stage,
      'order': instance.order,
      'linkedMatchId': instance.linkedMatchId,
    };

Playoffs _$PlayoffsFromJson(Map<String, dynamic> json) => Playoffs(
      enabled: json['enabled'] as bool? ?? false,
      type: json['type'] as String? ?? 'single_elimination',
      qualifiers: (json['qualifiers'] as num?)?.toInt() ?? 8,
      includeQuarterfinals: json['includeQuarterfinals'] as bool? ?? true,
      includeSemifinals: json['includeSemifinals'] as bool? ?? true,
      includeFinal: json['includeFinal'] as bool? ?? true,
      includeThirdPlace: json['includeThirdPlace'] as bool? ?? false,
      seedingRule:
          json['seedingRule'] as String? ?? 'standings_points_then_tiebreakers',
    );

Map<String, dynamic> _$PlayoffsToJson(Playoffs instance) => <String, dynamic>{
      'enabled': instance.enabled,
      'type': instance.type,
      'qualifiers': instance.qualifiers,
      'includeQuarterfinals': instance.includeQuarterfinals,
      'includeSemifinals': instance.includeSemifinals,
      'includeFinal': instance.includeFinal,
      'includeThirdPlace': instance.includeThirdPlace,
      'seedingRule': instance.seedingRule,
    };
