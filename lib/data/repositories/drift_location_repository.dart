import 'package:drift/drift.dart';
import 'package:darts_app/data/local/database.dart';
import 'package:darts_app/domain/location.dart' as domain;
import 'package:darts_app/domain/interfaces/i_location_repository.dart';

class DriftLocationRepository implements ILocationRepository {
  final AppDatabase _db;

  DriftLocationRepository(this._db);

  domain.Location _mapRowToEntity(Location row) {
    return domain.Location(
      id: row.id,
      name: row.name,
    );
  }

  LocationsCompanion _mapEntityToCompanion(domain.Location entity) {
    return LocationsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
    );
  }

  @override
  Stream<List<domain.Location>> watchAllLocations() {
    return _db.select(_db.locations).watch().map(
      (rows) => rows.map(_mapRowToEntity).toList(),
    );
  }

  @override
  Future<List<domain.Location>> getAllLocations() {
    return _db.select(_db.locations).get().then(
      (rows) => rows.map(_mapRowToEntity).toList(),
    );
  }

  @override
  Future<domain.Location?> getLocation(String id) async {
    final row = await (_db.select(_db.locations)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapRowToEntity(row);
  }

  @override
  Future<void> saveLocation(domain.Location location) async {
    // Upsert logic: insert or replace
    await _db.into(_db.locations).insertOnConflictUpdate(_mapEntityToCompanion(location));
  }

  @override
  Future<void> deleteLocation(String id) async {
    // Check if used in Matches? User requirement: "Prevent deleting a location if it’s used by existing matches OR provide a reassignment flow"
    // For now, I'll just delete. Implementing constraint check requires querying Matches table.
    
    // Check constraint
    final matchesCount = await (_db.select(_db.matches)..where((m) => m.locationId.equals(id))).get().then((l) => l.length);
    if (matchesCount > 0) {
      throw Exception('Cannot delete location used in $matchesCount matches.');
    }

    await (_db.delete(_db.locations)..where((t) => t.id.equals(id))).go();
  }
}
