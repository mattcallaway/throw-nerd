import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: DartsApp()));
}

class DartsApp extends ConsumerWidget {
  const DartsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);
    
    return MaterialApp(
      title: 'Pro Darts Scorer',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Always dark based
      darkTheme: appTheme.materialTheme,
      home: const HomeScreen(),
    );
  }
}
