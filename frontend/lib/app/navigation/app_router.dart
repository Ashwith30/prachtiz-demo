import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/layouts/app_shell.dart';
import '../../shared/layouts/receptionist_shell.dart';
import '../../shared/layouts/patient_shell.dart';
import '../../shared/services/auth_service.dart';
import 'app_route_paths.dart';

// ── Auth Screens ─────────────────────────────────────────────────────────────
import '../../features/auth/presentation/pages/role_selector_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';

// ── Doctor Screens ────────────────────────────────────────────────────────────
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/patients/presentation/pages/patient_overview_screen.dart';
import '../../features/patients/presentation/pages/patients_list_screen.dart';
import '../../features/appointments/presentation/pages/appointments_screen.dart';
import '../../features/health_records/presentation/pages/health_records_screen.dart';
import '../../features/prescriptions/presentation/pages/prescriptions_screen.dart';
import '../../features/lab_results/presentation/pages/lab_results_screen.dart';
import '../../features/vaccinations/presentation/pages/vaccinations_screen.dart';
import '../../features/telemedicine/presentation/pages/telemedicine_screen.dart';
import '../../features/consultation/presentation/pages/consultation_screen.dart';
import '../../features/staff/presentation/pages/staff_screen.dart';
import '../../features/staff/presentation/pages/doctor_schedule_screen.dart';
import '../../features/tasks/presentation/pages/task_board_screen.dart';
import '../../features/vitals/presentation/pages/vitals_monitor_screen.dart';
import '../../features/billing/presentation/pages/billing_screen.dart';
import '../../features/invoices/presentation/pages/invoices_screen.dart';
import '../../features/services/presentation/pages/services_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';

// ── Receptionist Screens ──────────────────────────────────────────────────────
import '../../features/receptionist/presentation/pages/receptionist_dashboard_screen.dart';

// ── Patient Portal Screens ────────────────────────────────────────────────────
import '../../features/patient_portal/presentation/pages/patient_home_screen.dart';
import '../../features/patient_portal/presentation/pages/patient_appointments_screen.dart';
import '../../features/patient_portal/presentation/pages/patient_prescriptions_screen.dart';
import '../../features/patient_portal/presentation/pages/patient_lab_results_screen.dart';
import '../../features/patient_portal/presentation/pages/patient_vitals_screen.dart';
import '../../features/patient_portal/presentation/pages/patient_billing_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
final GlobalKey<NavigatorState> _receptionistShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'receptionist');
final GlobalKey<NavigatorState> _patientShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'patient');

UserRole _parseRoleString(String? roleStr) {
  switch (roleStr) {
    case 'doctor':       return UserRole.doctor;
    case 'receptionist': return UserRole.receptionist;
    case 'patient':      return UserRole.patient;
    default:             return UserRole.doctor;
  }
}

// ── Redirect guard ────────────────────────────────────────────────────────────
String? _guard(BuildContext context, GoRouterState state) {
  final auth   = AuthService.instance;
  final path   = state.uri.path;
  final isAuth = path == AppRoutePaths.roleSelect ||
                 path == AppRoutePaths.login       ||
                 path == AppRoutePaths.signup;

  debugPrint('*** [GoRouter Guard] path: "$path", isLoggedIn: ${auth.isLoggedIn}, role: ${auth.role}, isAuth: $isAuth');

  if (!auth.isLoggedIn && !isAuth) return AppRoutePaths.roleSelect;

  if (auth.isLoggedIn) {
    // Prevent logged-in users from accessing auth pages
    if (isAuth) {
      switch (auth.role) {
        case UserRole.doctor:       return AppRoutePaths.dashboard;
        case UserRole.receptionist: return AppRoutePaths.receptionistDashboard;
        case UserRole.patient:      return AppRoutePaths.patientHome;
        case null:                  return AppRoutePaths.roleSelect;
      }
    }

    // Role-based route protection (RBAC)
    if (auth.role == UserRole.receptionist && !path.startsWith('/receptionist')) {
      return AppRoutePaths.receptionistDashboard;
    }
    if (auth.role == UserRole.patient && !path.startsWith('/patient')) {
      return AppRoutePaths.patientHome;
    }
    if (auth.role == UserRole.doctor && (path.startsWith('/receptionist') || path.startsWith('/patient'))) {
      return AppRoutePaths.dashboard;
    }
  }
  return null;
}

CustomTransitionPage<void> _transitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final offset = Tween<Offset>(
        begin: const Offset(0.018, 0),
        end: Offset.zero,
      ).animate(curved);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutePaths.roleSelect,
  redirect: _guard,
  refreshListenable: AuthService.instance,
  routes: [

    // ── Auth routes (no shell) ────────────────────────────────────────────
    GoRoute(
      path: AppRoutePaths.roleSelect,
      pageBuilder: (context, state) => _transitionPage(
        state: state, child: const RoleSelectorScreen()),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      pageBuilder: (context, state) {
        final roleStr = state.uri.queryParameters['role'];
        final role = _parseRoleString(roleStr);
        return _transitionPage(state: state, child: LoginScreen(role: role));
      },
    ),
    GoRoute(
      path: AppRoutePaths.signup,
      pageBuilder: (context, state) {
        final roleStr = state.uri.queryParameters['role'];
        final role = _parseRoleString(roleStr);
        return _transitionPage(state: state, child: SignupScreen(role: role));
      },
    ),

    // ── Doctor shell ──────────────────────────────────────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(
        activeRoute: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(path: AppRoutePaths.dashboard,
          pageBuilder: (c, s) => _transitionPage(state: s, child: const DashboardScreen())),
        GoRoute(path: AppRoutePaths.analytics,
          pageBuilder: (c, s) => _transitionPage(state: s, child: const AnalyticsScreen())),
        GoRoute(path: AppRoutePaths.patientOverview,
          pageBuilder: (c, s) => _transitionPage(state: s, child: PatientOverviewScreen())),
        GoRoute(path: AppRoutePaths.appointments,
          pageBuilder: (c, s) => _transitionPage(state: s, child: AppointmentsScreen())),
        GoRoute(path: AppRoutePaths.healthRecords,
          pageBuilder: (c, s) => _transitionPage(state: s, child: HealthRecordsScreen())),
        GoRoute(path: AppRoutePaths.prescriptions,
          pageBuilder: (c, s) => _transitionPage(state: s, child: PrescriptionsScreen())),
        GoRoute(path: AppRoutePaths.labResults,
          pageBuilder: (c, s) => _transitionPage(state: s, child: LabResultsScreen())),
        GoRoute(path: AppRoutePaths.vaccinations,
          pageBuilder: (c, s) => _transitionPage(state: s, child: VaccinationsScreen())),
        GoRoute(path: AppRoutePaths.telemedicine,
          pageBuilder: (c, s) => _transitionPage(state: s, child: TelemedicineScreen())),
        GoRoute(path: AppRoutePaths.consultation,
          pageBuilder: (c, s) => _transitionPage(state: s, child: ConsultationScreen())),
        GoRoute(path: AppRoutePaths.staff,
          pageBuilder: (c, s) => _transitionPage(state: s, child: StaffScreen())),
        GoRoute(path: AppRoutePaths.doctorSchedule,
          pageBuilder: (c, s) => _transitionPage(state: s, child: DoctorScheduleScreen())),
        GoRoute(path: AppRoutePaths.vitals,
          pageBuilder: (c, s) => _transitionPage(state: s, child: VitalsMonitorScreen())),
        GoRoute(path: AppRoutePaths.patients,
          pageBuilder: (c, s) => _transitionPage(state: s, child: PatientsListScreen())),
        GoRoute(path: AppRoutePaths.tasks,
          pageBuilder: (c, s) => _transitionPage(state: s, child: TaskBoardScreen())),
        GoRoute(path: AppRoutePaths.billing,
          pageBuilder: (c, s) => _transitionPage(state: s, child: BillingScreen())),
        GoRoute(path: AppRoutePaths.invoices,
          pageBuilder: (c, s) => _transitionPage(state: s, child: InvoicesScreen())),
        GoRoute(path: AppRoutePaths.services,
          pageBuilder: (c, s) => _transitionPage(state: s, child: ServicesScreen())),
        GoRoute(path: AppRoutePaths.settings,
          pageBuilder: (c, s) => _transitionPage(state: s, child: SettingsScreen())),
      ],
    ),

    // ── Receptionist shell ────────────────────────────────────────────────
    ShellRoute(
      navigatorKey: _receptionistShellKey,
      builder: (context, state, child) => ReceptionistShell(
        activeRoute: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(path: AppRoutePaths.receptionistDashboard,
          pageBuilder: (c, s) => _transitionPage(state: s, child: const ReceptionistDashboardScreen())),
        GoRoute(path: AppRoutePaths.receptionistPatients,
          pageBuilder: (c, s) => _transitionPage(state: s, child: PatientsListScreen())),
        GoRoute(path: AppRoutePaths.receptionistBilling,
          pageBuilder: (c, s) => _transitionPage(state: s, child: BillingScreen())),
        GoRoute(path: AppRoutePaths.receptionistTasks,
          pageBuilder: (c, s) => _transitionPage(state: s, child: TaskBoardScreen())),
        GoRoute(path: AppRoutePaths.receptionistSchedule,
          pageBuilder: (c, s) => _transitionPage(state: s, child: DoctorScheduleScreen())),
        GoRoute(path: AppRoutePaths.receptionistSettings,
          pageBuilder: (c, s) => _transitionPage(state: s, child: SettingsScreen())),
      ],
    ),

    // ── Patient shell ─────────────────────────────────────────────────────
    ShellRoute(
      navigatorKey: _patientShellKey,
      builder: (context, state, child) => PatientShell(
        activeRoute: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(path: AppRoutePaths.patientHome,
          pageBuilder: (c, s) => _transitionPage(state: s, child: const PatientHomeScreen())),
        GoRoute(path: AppRoutePaths.patientAppointments,
          pageBuilder: (c, s) => _transitionPage(state: s, child: const PatientAppointmentsScreen())),
        GoRoute(path: AppRoutePaths.patientPrescriptions,
          pageBuilder: (c, s) => _transitionPage(state: s, child: const PatientPrescriptionsScreen())),
        GoRoute(path: AppRoutePaths.patientLabResults,
          pageBuilder: (c, s) => _transitionPage(state: s, child: const PatientLabResultsScreen())),
        GoRoute(path: AppRoutePaths.patientVitals,
          pageBuilder: (c, s) => _transitionPage(state: s, child: const PatientVitalsScreen())),
        GoRoute(path: AppRoutePaths.patientBilling,
          pageBuilder: (c, s) => _transitionPage(state: s, child: const PatientBillingScreen())),
        GoRoute(path: AppRoutePaths.patientSettings,
          pageBuilder: (c, s) => _transitionPage(state: s, child: SettingsScreen())),
      ],
    ),
  ],
);
