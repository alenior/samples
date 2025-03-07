class Medication {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final List<DateTime> reminderTimes;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.reminderTimes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'reminderTimes': reminderTimes.map((dt) => dt.toIso8601String()).toList(),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      instructions: map['instructions'] as String,
      reminderTimes: (map['reminderTimes'] as List<dynamic>)
          .map((dt) => DateTime.parse(dt as String))
          .toList(),
    );
  }
}