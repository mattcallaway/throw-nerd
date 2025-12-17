
import 'scoring/models.dart';

class GameMatch {
  final String id;
  final GameConfig config;
  final List<String> playerIds;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final String? winnerId;
  final bool isCanceled;
  
  // Maybe locationId
  final String? locationId;
  final String? leagueId;
  final String? source;
  final String? settingsJson;
  final String? complianceStatus;

  const GameMatch({
    required this.id,
    required this.config,
    required this.playerIds,
    required this.createdAt,
    this.finishedAt,
    this.winnerId,
    this.isCanceled = false,
    this.locationId,
    this.leagueId,
    this.source,
    this.settingsJson,
    this.complianceStatus,
  });
}
