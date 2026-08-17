import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/sidebar/sidebar.dart';
import '../widgets/topbar/topbar.dart';
import '../../shared/services/settings_manager.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final String activeRoute;

  const AppShell({
    super.key,
    required this.child,
    required this.activeRoute,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool? _manuallyCollapsed;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getTitleForRoute(String route) {
    switch (route) {
      case '/':
        return 'Clinical Dashboard';
      case '/analytics':
        return 'Practice Performance Analytics';
      case '/patient-overview':
        return 'Patient Case Overview';
      case '/appointments':
        return 'Appointments Scheduler Queue';
      case '/health-records':
        return 'EMR Health Records Archive';
      case '/prescriptions':
        return 'Digital Rx Prescriptions Builder';
      case '/lab-results':
        return 'Laboratory Diagnostic Reports';
      case '/vaccinations':
        return 'Immunization Timeline & Logs';
      case '/telemedicine':
        return 'Telehealth Secure Session Grid';
      case '/consultation':
        return 'Active SOAP Consultation Notes';
      case '/staff':
        return 'Practitioner & Nurse Directory';
      case '/tasks':
        return 'Administrative Task Kanban Board';
      case '/vitals':
        return 'ICU Live Vitals Telemetry';
      case '/patients':
        return 'Registered Patient Directory';
      case '/doctor-schedule':
        return 'Doctor Roster Availability Planner';
      case '/billing':
        return 'POS Billing & Checkout Console';
      case '/invoices':
        return 'Issued Invoices Ledger';
      case '/services':
        return 'Services List Tariff Configuration';
      case '/settings':
        return 'Clinic Profile System Settings';
      default:
        return 'PraCHtiz Management System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isMobile = screenWidth < 600;
    final String pageTitle = _getTitleForRoute(widget.activeRoute);

    // Determine collapse state: manual override > auto-collapse on small screens
    final bool isCollapsed = _manuallyCollapsed ?? (screenWidth < 1200);

    void toggleSidebar() {
      setState(() {
        _manuallyCollapsed = !isCollapsed;
      });
    }

    return ListenableBuilder(
      listenable: SettingsManager.instance,
      builder: (context, _) {
        return Scaffold(
          key: _scaffoldKey,
          // Mobile drawer — no logo in drawer either; sidebar component handles it
          drawer: isMobile
              ? Drawer(
                  child: AppSidebar(
                    activeRoute: widget.activeRoute,
                    isCollapsed: false,
                  ),
                )
              : null,
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(color: Theme.of(context).scaffoldBackgroundColor),
              ),

              // ── Main layout ─────────────────────────────────────────────────────
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Unified topbar (includes logo panel synced to sidebar) ────
                    AppTopbar(
                      pageTitle: pageTitle,
                      isCollapsed: isCollapsed,
                      // Logo area tap toggles sidebar (desktop/tablet only)
                      onLogoAreaTap: isMobile ? null : toggleSidebar,
                      onMenuPressed: () {
                        if (isMobile) {
                          _scaffoldKey.currentState?.openDrawer();
                        }
                      },
                    ),

                    // ── Body row: sidebar + content ──────────────────────────────
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isMobile)
                            AppSidebar(
                              activeRoute: widget.activeRoute,
                              isCollapsed: isCollapsed,
                              onToggle: toggleSidebar,
                            ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(0.012, 0),
                                  end: Offset.zero,
                                ).animate(animation);

                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(widget.activeRoute),
                                child: widget.child,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
