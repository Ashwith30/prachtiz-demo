class AppRoutePaths {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String roleSelect  = '/role-select';
  static const String login       = '/login';
  static const String signup      = '/signup';

  static String loginPath(String role) => '/login?role=$role';
  static String signupPath(String role) => '/signup?role=$role';

  // ── Doctor (existing) ────────────────────────────────────────────────────
  static const String dashboard = '/';
  static const String analytics = '/analytics';
  static const String patientOverview = '/patient-overview';
  
  // Clinical Services
  static const String appointments = '/appointments';
  static const String healthRecords = '/health-records';
  static const String prescriptions = '/prescriptions';
  static const String labResults = '/lab-results';
  static const String vaccinations = '/vaccinations';
  static const String telemedicine = '/telemedicine';
  static const String consultation = '/consultation';

  // Management
  static const String staff = '/staff';
  static const String doctorSchedule = '/doctor-schedule';
  static const String vitals = '/vitals';
  static const String patients = '/patients';
  static const String patientDetails = '/patients/:id';
  static const String tasks = '/tasks';

  // Admin
  static const String billing = '/billing';
  static const String invoices = '/invoices';
  static const String services = '/services';
  static const String settings = '/settings';

  // ── Receptionist ──────────────────────────────────────────────────────────
  static const String receptionistDashboard = '/receptionist';
  static const String receptionistPatients  = '/receptionist/patients';
  static const String receptionistBilling   = '/receptionist/billing';
  static const String receptionistTasks     = '/receptionist/tasks';
  static const String receptionistSchedule  = '/receptionist/schedule';
  static const String receptionistSettings  = '/receptionist/settings';

  // ── Patient Portal ────────────────────────────────────────────────────────
  static const String patientHome           = '/patient';
  static const String patientAppointments   = '/patient/appointments';
  static const String patientPrescriptions  = '/patient/prescriptions';
  static const String patientLabResults     = '/patient/lab-results';
  static const String patientVitals         = '/patient/vitals';
  static const String patientBilling        = '/patient/billing';
  static const String patientSettings       = '/patient/settings';
}
