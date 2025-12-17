import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../providers/di_providers.dart';
import '../theme/app_themes.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  Future<void> _exportDb(BuildContext context) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'darts_app.sqlite'));
    
    if (await file.exists()) {
       await Share.shareXFiles([XFile(file.path)], text: 'Darts App Backup');
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No database found to export')));
    }
  }

  Future<void> _importDb(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = File(result.files.single.path!);
      
      final dbFolder = await getApplicationDocumentsDirectory();
      final target = File(p.join(dbFolder.path, 'darts_app.sqlite'));
      
      try {
         // Create backup of current just in case?
         if (await target.exists()) {
            await target.copy(p.join(dbFolder.path, 'darts_app.sqlite.bak'));
         }
         
         await file.copy(target.path);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import success! Please restart the app.')));
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Theme Selector
            Text('Visual Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<AppThemeMode>(
              segments: const [
                ButtonSegment(value: AppThemeMode.modern, label: Text('Modern Dark')),
                ButtonSegment(value: AppThemeMode.neon, label: Text('Retro Neon')),
              ],
              selected: {theme.mode},
              onSelectionChanged: (s) {
                 ref.read(appThemeProvider.notifier).setMode(s.first);
              },
            ),
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 32),
            
            // Backup Actions
            Text('Data Management', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Export Database'),
              onPressed: () => _exportDb(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
               icon: const Icon(Icons.download),
               label: const Text('Import Database'),
               onPressed: () => _importDb(context),
            ),
             const SizedBox(height: 16),
             const Text('Warning: Import will replace all current data.', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
