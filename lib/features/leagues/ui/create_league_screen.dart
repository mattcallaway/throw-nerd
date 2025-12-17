import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/league_repository.dart';

class CreateLeagueScreen extends ConsumerStatefulWidget {
  const CreateLeagueScreen({super.key});

  @override
  ConsumerState<CreateLeagueScreen> createState() => _CreateLeagueScreenState();
}

class _CreateLeagueScreenState extends ConsumerState<CreateLeagueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedProvider = 'gdrive'; // Default
  String _selectedMode = 'informal';
  bool _isLoading = false;

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final repo = ref.read(leagueRepositoryProvider);
      await repo.createLeague(_nameController.text.trim(), _selectedProvider, mode: _selectedMode);
      
      if (mounted) {
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Create League')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'League Name',
                  hintText: 'e.g. Office Darts 2024',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 24),
              const Text('Storage Provider', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildProviderOption('gdrive', 'Google Drive', Icons.add_to_drive),
              _buildProviderOption('dropbox', 'Dropbox', Icons.folder_shared),
              
              const SizedBox(height: 24),
              const Text('League Mode', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildModeOption('informal', 'Informal', 'Casual play, aggregate stats'),
              _buildModeOption('formal', 'Formal', 'Seasons, schedules, and strict rules'),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _create,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create League'),
                ),
              ),
            ],
          ),
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

  Widget _buildModeOption(String id, String label, String subtitle) {
     return RadioListTile<String>(
        value: id,
        groupValue: _selectedMode,
        onChanged: (val) => setState(() => _selectedMode = val!),
        title: Text(label),
        subtitle: Text(subtitle),
     );
  }
}
