enum VitalStatus { normal, warning, critical, inactive }

class VitalReading {
  final int heartRate;
  final String bloodPressure;
  final double temperature;
  final int spo2;
  final String timestamp;

  VitalReading({
    required this.heartRate,
    required this.bloodPressure,
    required this.temperature,
    required this.spo2,
    required this.timestamp,
  });
}

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String contact;
  final String condition;
  final VitalStatus vitalStatus;
  final String dob;
  final List<String> allergies;
  final List<VitalReading> vitalsHistory;
  final String? statusLabel;
  final String? doctorName;
  final String? roomNumber;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.condition,
    required this.vitalStatus,
    required this.dob,
    this.allergies = const [],
    this.vitalsHistory = const [],
    this.statusLabel,
    this.doctorName,
    this.roomNumber,
  });

  String get initials {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return "${names[0][0]}${names[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}
