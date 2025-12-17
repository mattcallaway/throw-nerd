import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  modern,
  neon,
}

class AppThemeData {
  final AppThemeMode mode;
  final ThemeData materialTheme;
  final Color boardBackground;
  final Color scoreColor;
  final Color activePlayerBorder;
  final Color activePlayerBackground;
  final List<Color> playerColors;
  
  // Interactive / Menu
  final Color keypadButtonBg;
  final Color keypadButtonFg;
  
  final Color dangerColor;
  final Color successColor;
  final Color warningColor;
  
  final Color menuNewMatch;
  final Color menuPlayers;
  final Color menuStats;
  final Color menuLocations;
  final Color menuSettings;
  final Color menuHistory;

  // Semantic / Component Colors
  // Premium Tokens
  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;
  final Color surfaceColor;
  final Color accentColor;
  
  // Design System constants (could be static but okay here)
  final double borderRadiusLarge = 24.0;
  final double borderRadiusMedium = 16.0;
  final double borderRadiusSmall = 8.0;

  AppThemeData({
    required this.mode,
    required this.materialTheme,
    required this.boardBackground,
    required this.scoreColor,
    required this.activePlayerBorder,
    required this.activePlayerBackground,
    required this.playerColors,
    required this.keypadButtonBg,
    required this.keypadButtonFg,
    required this.dangerColor,
    required this.successColor,
    required this.warningColor,
    required this.menuNewMatch,
    required this.menuPlayers,
    required this.menuStats,
    required this.menuLocations,
    required this.menuSettings,
    required this.menuHistory,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.surfaceColor,
    required this.accentColor,
  });

  factory AppThemeData.modern() {
    final base = ThemeData.dark();
    const bgStart = Color(0xFF1E1E2C);
    const bgEnd = Color(0xFF161621);
    
    return AppThemeData(
      mode: AppThemeMode.modern,
      materialTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
          surface: const Color(0xFF252535),
        ),
        scaffoldBackgroundColor: bgStart,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      boardBackground: bgStart, // Use gradient in UI
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bgStart, bgEnd],
      ),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF2A2A3D).withOpacity(0.9), const Color(0xFF222233).withOpacity(0.9)],
      ),
      surfaceColor: const Color(0xFF252535),
      accentColor: Colors.tealAccent,
      scoreColor: Colors.white,
      activePlayerBorder: Colors.teal,
      activePlayerBackground: Colors.teal.withOpacity(0.15),
      playerColors: [
        Colors.blue.shade400,
        Colors.red.shade400,
        Colors.green.shade400,
        Colors.orange.shade400,
        Colors.purple.shade400,
      ],
      keypadButtonBg: const Color(0xFF2C2C3E), // Softer key color
      keypadButtonFg: Colors.white,
      dangerColor: const Color(0xFFFF5252),
      successColor: const Color(0xFF69F0AE),
      warningColor: const Color(0xFFFFD740),
      menuNewMatch: const Color(0xFF00796B), // Teal 700
      menuPlayers: const Color(0xFF1565C0), // Blue 800
      menuStats: const Color(0xFFEF6C00), // Orange 800
      menuLocations: const Color(0xFF7B1FA2), // Purple 700
      menuSettings: const Color(0xFF424242),
      menuHistory: const Color(0xFF00695C),
    );
  }

  factory AppThemeData.neon() {
    final base = ThemeData.dark();
    // Darker, richer background for neon pop
    const bgStart = Color(0xFF0D0D15);
    const bgEnd = Color(0xFF000000);
    const neonGreen = Color(0xFF39FF14);
    
    return AppThemeData(
      mode: AppThemeMode.neon,
      materialTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: neonGreen,
          secondary: Color(0xFFD500F9), // Neon Purple
          surface: Color(0xFF14141F),
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(bodyColor: Colors.white, displayColor: Colors.white), // Outfit is modern geometric
      ),
      boardBackground: Colors.black,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgStart, bgEnd],
      ),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF1F1F2E).withOpacity(0.9), const Color(0xFF14141F).withOpacity(0.9)],
      ),
      surfaceColor: const Color(0xFF14141F),
      accentColor: neonGreen,
      scoreColor: neonGreen,
      activePlayerBorder: const Color(0xFF00FFFF), // Cyan
      activePlayerBackground: const Color(0xFF00FFFF).withOpacity(0.05),
      playerColors: [
        const Color(0xFF00FFFF), // Cyan
        const Color(0xFFFF00FF), // Magenta
        const Color(0xFFCCFF00), // Electric Lime
        const Color(0xFFFF3333), // Neon Red
        const Color(0xFFBF00FF), // Electric Purple
      ],
      keypadButtonBg: const Color(0xFF1A1A24),
      keypadButtonFg: neonGreen,
      dangerColor: const Color(0xFFFF1744), 
      successColor: neonGreen, 
      warningColor: const Color(0xFFFFEA00),
      menuNewMatch: const Color(0xFF1B5E20), // Green 900
      menuPlayers: const Color(0xFF0D47A1), // Blue 900
      menuStats: const Color(0xFFE65100), // Orange 900
      menuLocations: const Color(0xFF4A148C), // Purple 900
      menuSettings: const Color(0xFF212121),
      menuHistory: const Color(0xFF004D40),
    );
  }
}
