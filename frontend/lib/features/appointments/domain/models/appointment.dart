enum AppointmentStatus { pending, active, checkedIn, completed }

class Appointment {
  final String id;
  final String patientName;
  final String doctorName;
  final String time;
  final String date;
  final String type; // "Telemedicine", "In-Person Consultation", "Follow-up Review"
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.time,
    required this.date,
    required this.type,
    required this.status,
  });

  Appointment copyWith({
    String? id,
    String? patientName,
    String? doctorName,
    String? time,
    String? date,
    String? type,
    AppointmentStatus? status,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      time: time ?? this.time,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}
