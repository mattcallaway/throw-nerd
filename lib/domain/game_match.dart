
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
  final String? settingsJson;

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
    this.settingsJson,
  });
}
