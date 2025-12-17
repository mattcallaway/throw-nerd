import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:darts_app/data/local/database.dart';
import 'package:darts_app/data/repositories/drift_player_repository.dart';
import 'package:darts_app/domain/player.dart' as domain;
import 'package:flutter/material.dart' show Colors;

void main() {
  late AppDatabase database;
  late DriftPlayerRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftPlayerRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('createPlayer adds a player', () async {
    final player = domain.Player(id: '1', name: 'Test Player', color: Colors.blue);
    await repository.createPlayer(player);

    final players = await repository.getAllPlayers();
    expect(players.length, 1);
    expect(players.first.name, 'Test Player');
  });

  test('deletePlayer removes a player', () async {
    final player = domain.Player(id: '1', name: 'To Delete', color: Colors.blue);
    await repository.createPlayer(player);
    
    await repository.deletePlayer('1');
    final players = await repository.getAllPlayers();
    expect(players, isEmpty);
  });
  
  test('updatePlayer modifies a player', () async {
    final player = domain.Player(id: '1', name: 'Original', color: Colors.blue);
    await repository.createPlayer(player);
    
    final updated = player.copyWith(name: 'Updated');
    await repository.updatePlayer(updated);
    
    final fetched = await repository.getPlayer('1');
    expect(fetched!.name, 'Updated');
  });
}
