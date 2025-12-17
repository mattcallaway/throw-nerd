import '../location.dart';

abstract class ILocationRepository {
  Stream<List<Location>> watchAllLocations();
  Future<List<Location>> getAllLocations();
  Future<Location?> getLocation(String id);
  Future<void> saveLocation(Location location);
  Future<void> deleteLocation(String id);
}
