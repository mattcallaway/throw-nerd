import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:darts_app/domain/player.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';

class PlayerFormDialog extends ConsumerStatefulWidget {
  final Player? playerToEdit;

  const PlayerFormDialog({super.key, this.playerToEdit});

  @override
  ConsumerState<PlayerFormDialog> createState() => _PlayerFormDialogState();
}

class _PlayerFormDialogState extends ConsumerState<PlayerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Color _selectedColor;

  // Preset Colors
  final List<Color> _colors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
    Colors.teal, Colors.pink, Colors.cyan, Colors.amber, Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playerToEdit?.name ?? '');
    _selectedColor = widget.playerToEdit?.color ?? _colors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(playerRepositoryProvider);
      final name = _nameController.text.trim();
      
      if (widget.playerToEdit != null) {
        // Update
        final updated = widget.playerToEdit!.copyWith(
          name: name,
          color: _selectedColor,
        );
        repo.updatePlayer(updated);
      } else {
        // Create
        final newPlayer = Player(
          id: const Uuid().v4(),
          name: name,
          color: _selectedColor,
          avatar: null, // Basic avatar support for now
        );
        repo.createPlayer(newPlayer);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    
    return AlertDialog(
      title: Text(widget.playerToEdit == null ? 'New Player' : 'Edit Player'),
      content: SingleChildScrollView(
         child: Form(
           key: _formKey,
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextFormField(
                 controller: _nameController,
                 decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                 validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
                 textCapitalization: TextCapitalization.words,
               ),
               const SizedBox(height: 16),
               const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
               const SizedBox(height: 8),
               Wrap(
                 spacing: 8,
                 runSpacing: 8,
                 children: _colors.map((c) => GestureDetector(
                   onTap: () => setState(() => _selectedColor = c),
                   child: Container(
                     width: 32, height: 32,
                     decoration: BoxDecoration(
                       color: c,
                       shape: BoxShape.circle,
                       border: _selectedColor.value == c.value 
                          ? Border.all(color: Colors.white, width: 3) 
                          : null,
                       boxShadow: _selectedColor.value == c.value
                          ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 8)]
                          : null,
                     ),
                   ),
                 )).toList(),
               ),
             ],
           ),
         ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _save, 
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.successColor,
            foregroundColor: Colors.black,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
