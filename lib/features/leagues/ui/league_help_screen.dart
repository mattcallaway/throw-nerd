import 'package:flutter/material.dart';

class LeagueHelpScreen extends StatelessWidget {
  const LeagueHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('League Manual')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            title: 'Overview',
            content: 'The League feature allows you to organize darts competitions with friends, track stats over time, and manage seasons.\n\nTwo Modes:\n• Informal: Just a group of friends playing. Stats are aggregated, but no schedule is enforced.\n• Formal: Structured seasons, schedules, standings, and rule enforcement.',
          ),
          _buildSection(
            title: 'Syncing & Data',
            content: 'Leagues are synced using your chosen Cloud Provider (e.g., Dropbox, Google Drive, JSON Bin).\n\n• The "Owner" controls the master data (rules, schedule).\n• Members "Sync" to pull the latest updates and upload their match results.\n• Always sync before playing to ensure you have the latest standings and rules.',
          ),
          _buildSection(
            title: 'Playing a League Match',
            content: '1. Go to "Setup Match" from the Home Screen.\n2. Check "League Game".\n3. Select your League.\n4. (Optional) Select players from the "League Members" list.\n5. Start Game!\n\nNote: If the league has specific rules (e.g., "501 Only", "Double Out"), the settings will be locked automatically.',
          ),
          _buildSection(
            title: 'For League Owners',
            content: 'As an owner, you have extra tools in the "Settings" menu:\n\n• Seasons: Create new seasons (e.g., "Fall 2024") to reset standings.\n• Schedule: Use the "Generate" wand to automatically create a Round Robin schedule for the season.\n• Rules: Enforce game types (X01) or strict scheduling.\n• Members: Ban/Unban members if needed.',
          ),
          _buildSection(
            title: 'Schedules (Formal Mode)',
            content: '1. Go to League Settings -> Manage Seasons.\n2. Create/Select a Season -> Schedule.\n3. Click the "Auto-Renew" icon in the top right to Generate a Round Robin schedule.\n4. Select the players involved.\n5. The app will generate weekly matchups.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: title == 'Overview',
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(content, style: const TextStyle(height: 1.5, fontSize: 15)),
          )
        ],
      ),
    );
  }
}
