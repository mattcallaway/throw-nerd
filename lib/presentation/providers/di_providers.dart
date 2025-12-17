import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart' hide Location, Player;
import '../../data/repositories/drift_player_repository.dart';
import '../../data/repositories/drift_match_repository.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../services/analytics/analytics_service.dart';
import '../../domain/interfaces/i_player_repository.dart';
import '../../domain/interfaces/i_match_repository.dart';
import '../../domain/interfaces/i_location_repository.dart';
import '../../data/repositories/drift_location_repository.dart';
import '../../domain/location.dart';
import '../../domain/player.dart';
import '../theme/app_themes.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Alias for compatibility if needed, or update usages
final databaseProvider = appDatabaseProvider;

final playerRepositoryProvider = Provider<IPlayerRepository>((ref) {
  return DriftPlayerRepository(ref.watch(databaseProvider));
});

final matchRepositoryProvider = Provider<IMatchRepository>((ref) {
  return DriftMatchRepository(ref.watch(databaseProvider));
});

final locationRepositoryProvider = Provider<ILocationRepository>((ref) {
  return DriftLocationRepository(ref.watch(databaseProvider));
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(databaseProvider));
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(analyticsRepositoryProvider));
});

// Theme Provider (StateNotifier allows switching)
final appThemeProvider = StateNotifierProvider<AppThemeNotifier, AppThemeData>((ref) {
  return AppThemeNotifier();
});

class AppThemeNotifier extends StateNotifier<AppThemeData> {
  AppThemeNotifier() : super(AppThemeData.modern()); // Default to Modern

  void setMode(AppThemeMode mode) {
    if (mode == AppThemeMode.neon) {
      state = AppThemeData.neon();
    } else {
      state = AppThemeData.modern();
    }
  }

  void toggle() {
    if (state.mode == AppThemeMode.modern) {
      setMode(AppThemeMode.neon);
    } else {
      setMode(AppThemeMode.modern);
    }
  }
}


final allPlayersProvider = StreamProvider<List<Player>>((ref) {
  return ref.watch(playerRepositoryProvider).watchAllPlayers();
});

final allLocationsProvider = FutureProvider<List<Location>>((ref) {
  return ref.watch(locationRepositoryProvider).getAllLocations();
});
