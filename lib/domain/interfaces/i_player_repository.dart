import '../player.dart';

abstract class IPlayerRepository {
  Stream<List<Player>> watchAllPlayers();
  Future<List<Player>> getAllPlayers();
  Future<Player?> getPlayer(String id);
  Future<void> createPlayer(Player player);
  Future<void> updatePlayer(Player player);
  Future<void> deletePlayer(String id);
}
