import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/database_service.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final DatabaseService _db = DatabaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  List<Medication> _medications = [];
  List<TimeOfDay> _reminderTimes = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final medications = await _db.getMedications();
      if (mounted) {
        setState(() {
          _medications = medications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load medications: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState?.validate() ?? false) {
      final medication = Medication(
        id: DateTime.now().toString(),
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        instructions: _instructionsController.text.trim(),
        reminderTimes: _reminderTimes.map((time) {
          final now = DateTime.now();
          return DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );
        }).toList(),
      );

      // Optimistic update
      setState(() {
        _medications.add(medication);
        _error = null;
      });

      try {
        await _db.insertMedication(medication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medication saved successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Revert optimistic update on error
        if (mounted) {
          setState(() {
            _medications.remove(medication);
            _error = 'Failed to save medication: ${e.toString()}';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_error!)),
          );
        }
      }
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    // Optimistic update
    final index = _medications.indexOf(medication);
    setState(() {
      _medications.remove(medication);
      _error = null;
    });

    try {
      await _db.deleteMedication(medication.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication deleted successfully')),
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      if (mounted) {
        setState(() {
          _medications.insert(index, medication);
          _error = 'Failed to delete medication: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }
    }
  }

  void _addReminderTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _reminderTimes.add(time);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _loadMedications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final medication = _medications[index];
                    return Dismissible(
                      key: Key(medication.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteMedication(medication),
                      child: ListTile(
                        title: Text(medication.name),
                        subtitle: Text(medication.dosage),
                        trailing: Text(
                          '${medication.reminderTimes.length} reminders',
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicationDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddMedicationDialog(BuildContext context) {
    _nameController.clear();
    _dosageController.clear();
    _instructionsController.clear();
    _reminderTimes.clear();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medication'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Medication Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter medication name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(labelText: 'Dosage'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter dosage';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(labelText: 'Instructions'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Reminder Times:'),
                Wrap(
                  spacing: 8,
                  children: [
                    ..._reminderTimes.map((time) => Chip(
                          label: Text(time.format(context)),
                          onDeleted: () => setState(() {
                            _reminderTimes.remove(time);
                          }),
                        )),
                    ActionChip(
                      label: const Text('Add Time'),
                      onPressed: _addReminderTime,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveMedication,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
