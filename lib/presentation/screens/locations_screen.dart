import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:darts_app/domain/location.dart';
import 'package:darts_app/presentation/providers/di_providers.dart';
import 'package:darts_app/presentation/theme/app_themes.dart';

class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final repo = ref.watch(locationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        backgroundColor: theme.boardBackground,
      ),
      body: StreamBuilder<List<Location>>(
        stream: repo.watchAllLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          final locations = snapshot.data ?? [];

          if (locations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.place_outlined, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text('No locations added.', style: TextStyle(color: Colors.grey)),
                   const SizedBox(height: 8),
                   ElevatedButton(
                     onPressed: () => _showLocationDialog(context, ref),
                     child: const Text('Add Location'),
                   ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final loc = locations[index];
              return Card(
                color: theme.materialTheme.cardTheme.color ?? Colors.white10,
                child: ListTile(
                  leading: Icon(Icons.place, color: theme.playerColors[index % theme.playerColors.length]),
                  title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       IconButton(
                         icon: const Icon(Icons.edit),
                         onPressed: () => _showLocationDialog(context, ref, locationToEdit: loc),
                       ),
                       IconButton(
                         icon: Icon(Icons.delete, color: theme.dangerColor),
                         onPressed: () => _confirmDelete(context, ref, loc),
                       ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.successColor,
        foregroundColor: Colors.black,
        onPressed: () => _showLocationDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, WidgetRef ref, {Location? locationToEdit}) {
    showDialog(
      context: context,
      builder: (_) => _LocationFormDialog(locationToEdit: locationToEdit),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Location loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Location?'),
        content: Text('Delete ${loc.name}? This will fail if matches are associated with it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
               try {
                 await ref.read(locationRepositoryProvider).deleteLocation(loc.id);
                 Navigator.pop(ctx);
               } catch (e) {
                 Navigator.pop(ctx);
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
               }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _LocationFormDialog extends ConsumerStatefulWidget {
  final Location? locationToEdit;
  const _LocationFormDialog({this.locationToEdit});

  @override
  ConsumerState<_LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends ConsumerState<_LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.locationToEdit?.name ?? '');
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(locationRepositoryProvider);
      final name = _nameController.text.trim();
      
      if (widget.locationToEdit != null) {
        repo.saveLocation(widget.locationToEdit!.copyWith(name: name));
      } else {
        repo.saveLocation(Location(id: const Uuid().v4(), name: name));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    return AlertDialog(
      title: Text(widget.locationToEdit == null ? 'Add Location' : 'Edit Location'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
          validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
          textCapitalization: TextCapitalization.words,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: theme.successColor, foregroundColor: Colors.black),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
