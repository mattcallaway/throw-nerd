import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../../domain/player.dart' as domain;
import '../../domain/interfaces/i_player_repository.dart';
import '../local/database.dart';

class DriftPlayerRepository implements IPlayerRepository {
  final AppDatabase _db;

  DriftPlayerRepository(this._db);

  domain.Player _mapRowToEntity(Player row) {
    return domain.Player(
      id: row.id,
      name: row.name,
      color: Color(row.color),
      avatar: row.avatar,
    );
  }

  PlayersCompanion _mapEntityToCompanion(domain.Player entity) {
    return PlayersCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      color: Value(entity.color.value),
      avatar: Value(entity.avatar),
    );
  }

  @override
  Stream<List<domain.Player>> watchAllPlayers() {
    return _db.select(_db.players).watch().map(
          (rows) => rows.map(_mapRowToEntity).toList(),
        );
  }

  @override
  Future<List<domain.Player>> getAllPlayers() {
    return _db.select(_db.players).get().then(
          (rows) => rows.map(_mapRowToEntity).toList(),
        );
  }

  @override
  Future<domain.Player?> getPlayer(String id) async {
    final row = await (_db.select(_db.players)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapRowToEntity(row);
  }

  @override
  Future<void> createPlayer(domain.Player player) async {
    await _db.into(_db.players).insert(_mapEntityToCompanion(player));
  }

  @override
  Future<void> updatePlayer(domain.Player player) async {
     await _db.update(_db.players).replace(_mapEntityToCompanion(player));
  }

  @override
  Future<void> deletePlayer(String id) async {
    await (_db.delete(_db.players)..where((tbl) => tbl.id.equals(id))).go();
  }
}
