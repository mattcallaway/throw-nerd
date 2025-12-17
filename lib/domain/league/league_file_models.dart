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
  
  LeagueFile({
    required this.schemaVersion,
    required this.leagueId,
    required this.name,
    required this.createdAt,
    required this.createdBy,
    required this.provider,
    required this.remoteRootPath,
    this.appMinVersion = 1,
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
