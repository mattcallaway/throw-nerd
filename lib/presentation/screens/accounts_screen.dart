import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_themes.dart';
import '../widgets/glass_card.dart';
import '../../services/auth/auth_coordinator.dart';
import '../providers/di_providers.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  // We need to track state of each provider
  // AuthCoordinator doesn't expose stream of auth state yet, just methods.
  // We'll call `isConnected` on init and refresh.
  
  Map<String, bool> _status = {};
  
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  
  Future<void> _refresh() async {
    final coord = ref.read(authCoordinatorProvider);
    final gdrive = await coord.isConnected('gdrive');
    final dbx = await coord.isConnected('dropbox');
    final firebase = await coord.isConnected('firebase');
    
    if (mounted) {
       setState(() {
          _status = {
            'gdrive': gdrive,
            'dropbox': dbx,
            'firebase': firebase,
          };
       });
    }
  }
  
  Future<void> _toggle(String providerId, bool currentStatus) async {
     final coord = ref.read(authCoordinatorProvider);
     if (currentStatus) {
       await coord.disconnect(providerId);
     } else {
       await coord.connect(providerId);
     }
     await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Connected Accounts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
               _ProviderTile(
                 name: 'Google Drive',
                 icon: Icons.add_to_drive,
                 isConnected: _status['gdrive'] ?? false,
                 onToggle: () => _toggle('gdrive', _status['gdrive'] ?? false),
               ),
               const SizedBox(height: 12),
               _ProviderTile(
                 name: 'Dropbox',
                 icon: Icons.folder, // Use generic for now or FontAwesome if available
                 isConnected: _status['dropbox'] ?? false,
                 onToggle: () => _toggle('dropbox', _status['dropbox'] ?? false),
               ),
               const SizedBox(height: 12),
               _ProviderTile(
                 name: 'Firebase (Cloud Sync)',
                 icon: Icons.cloud,
                 isConnected: _status['firebase'] ?? false,
                 onToggle: () => _toggle('firebase', _status['firebase'] ?? false),
               ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isConnected;
  final VoidCallback onToggle;
  
  const _ProviderTile({required this.name, required this.icon, required this.isConnected, required this.onToggle});
  
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 32),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(isConnected ? 'Connected' : 'Not Connected', 
            style: TextStyle(color: isConnected ? Colors.greenAccent : Colors.white54)),
        trailing: ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
             backgroundColor: isConnected ? Colors.red.withOpacity(0.8) : Colors.blue,
          ),
          child: Text(isConnected ? 'Disconnect' : 'Connect'),
        ),
      ),
    );
  }
}
