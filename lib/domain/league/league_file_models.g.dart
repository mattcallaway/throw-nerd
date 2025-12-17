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
