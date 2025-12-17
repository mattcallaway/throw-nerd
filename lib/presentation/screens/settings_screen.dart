import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_themes.dart';
import '../widgets/glass_card.dart';
import 'backup_screen.dart';
import 'accounts_screen.dart';
import '../providers/di_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
               _SettingTile(
                 title: 'Data & Backup',
                 subtitle: 'Export/Import database',
                 icon: Icons.save_rounded,
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen())),
               ),
               const SizedBox(height: 12),
               _SettingTile(
                 title: 'Connected Accounts',
                 subtitle: 'Manage Google Drive / Dropbox connections',
                 icon: Icons.cloud_sync_rounded,
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountsScreen())),
               ),
               // Add Theme toggle or others later
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  
  const _SettingTile({required this.title, required this.subtitle, required this.icon, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      ),
    );
  }
}
