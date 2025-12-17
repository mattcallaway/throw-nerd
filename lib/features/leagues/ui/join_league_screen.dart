import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/league_repository.dart';

class JoinLeagueScreen extends ConsumerStatefulWidget {
  const JoinLeagueScreen({super.key});

  @override
  ConsumerState<JoinLeagueScreen> createState() => _JoinLeagueScreenState();
}

class _JoinLeagueScreenState extends ConsumerState<JoinLeagueScreen> {
  final _codeController = TextEditingController();
  String _selectedProvider = 'gdrive';
  bool _isLoading = false;

  Future<void> _join() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(leagueRepositoryProvider);
      await repo.joinLeague(code, _selectedProvider);

      if (mounted) {
         // Pop back to list, hopefully list refreshes automatically via StreamProvider
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined league successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join League')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Enter the League Invite Code or Folder Link shared with you.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Invite Code / Link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Align(alignment: Alignment.centerLeft, child: Text('Storage Provider', style: TextStyle(fontWeight: FontWeight.bold))),
            _buildProviderOption('gdrive', 'Google Drive', Icons.add_to_drive),
            _buildProviderOption('dropbox', 'Dropbox', Icons.folder_shared),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _join,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Join League'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderOption(String id, String label, IconData icon) {
    return RadioListTile<String>(
      value: id,
      groupValue: _selectedProvider,
      onChanged: (val) => setState(() => _selectedProvider = val!),
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
