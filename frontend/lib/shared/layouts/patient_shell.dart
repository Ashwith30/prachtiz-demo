import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/services/auth_service.dart';
import '../../app/navigation/app_route_paths.dart';

class PatientShell extends StatelessWidget {
  final Widget child;
  final String activeRoute;

  const PatientShell({
    super.key,
    required this.child,
    required this.activeRoute,
  });

  static const _accent = Color(0xFF8B5CF6); // Patient purple
  static const Color _sidebarBg = Color(0xFF0D0B1E);

  static const _navItems = [
    _NavItem(label: 'Home',          icon: Icons.home_outlined,           path: AppRoutePaths.patientHome),
    _NavItem(label: 'Appointments',  icon: Icons.calendar_month_outlined,  path: AppRoutePaths.patientAppointments),
    _NavItem(label: 'Prescriptions', icon: Icons.medication_outlined,      path: AppRoutePaths.patientPrescriptions),
    _NavItem(label: 'Lab Results',   icon: Icons.biotech_outlined,         path: AppRoutePaths.patientLabResults),
    _NavItem(label: 'Vitals',        icon: Icons.monitor_heart_outlined,   path: AppRoutePaths.patientVitals),
    _NavItem(label: 'Billing',       icon: Icons.receipt_long_outlined,    path: AppRoutePaths.patientBilling),
    _NavItem(label: 'Settings',      icon: Icons.settings_outlined,        path: AppRoutePaths.patientSettings),
  ];

  String _titleForRoute(String r) {
    switch (r) {
      case AppRoutePaths.patientHome:          return 'My Health Portal';
      case AppRoutePaths.patientAppointments:  return 'My Appointments';
      case AppRoutePaths.patientPrescriptions: return 'My Prescriptions';
      case AppRoutePaths.patientLabResults:    return 'Lab Results';
      case AppRoutePaths.patientVitals:        return 'My Vitals';
      case AppRoutePaths.patientBilling:       return 'My Billing';
      case AppRoutePaths.patientSettings:      return 'Settings';
      default: return 'Patient Portal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 768; // Bottom nav on mobile, sidebar on desktop/tablet
    final auth = AuthService.instance;

    if (isMobile) {
      return _MobilePatientShell(
        child: child,
        activeRoute: activeRoute,
        title: _titleForRoute(activeRoute),
        auth: auth,
        navItems: _navItems,
        accent: _accent,
      );
    }

    // Desktop/Tablet — sidebar layout
    return Scaffold(
      backgroundColor: const Color(0xFF080B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0B1E),
        elevation: 0,
        title: Text(_titleForRoute(activeRoute),
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _accent.withOpacity(0.15),
              child: Text(auth.session?.initials ?? 'P',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _accent)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF1A1540)),
        ),
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: _sidebarBg,
            child: Column(
              children: [
                // Brand header
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1A1540))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_rounded, color: _accent, size: 20),
                      const SizedBox(width: 8),
                      Text('Patient Portal',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: _navItems.map((item) {
                      final isActive = activeRoute == item.path;
                      return InkWell(
                        onTap: () => context.go(item.path),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? _accent.withOpacity(0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(item.icon, size: 20,
                                color: isActive ? _accent : Colors.white.withOpacity(0.45)),
                              const SizedBox(width: 10),
                              Text(item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                  color: isActive ? _accent : Colors.white.withOpacity(0.65),
                                )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // User + logout
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1A1540)))),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 16, backgroundColor: _accent.withOpacity(0.15),
                        child: Text(auth.session?.initials ?? 'P',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _accent))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(auth.session?.fullName ?? 'Patient',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                          Text('Patient', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                        ]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white38, size: 18),
                        onPressed: () { auth.logout(); context.go(AppRoutePaths.roleSelect); },
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Mobile patient shell — bottom navigation bar ─────────────────────────────
class _MobilePatientShell extends StatelessWidget {
  final Widget child;
  final String activeRoute;
  final String title;
  final AuthService auth;
  final List<_NavItem> navItems;
  final Color accent;

  const _MobilePatientShell({
    required this.child,
    required this.activeRoute,
    required this.title,
    required this.auth,
    required this.navItems,
    required this.accent,
  });

  // Only show 5 items in the bottom bar (most important)
  static const _bottomItems = [
    AppRoutePaths.patientHome,
    AppRoutePaths.patientAppointments,
    AppRoutePaths.patientPrescriptions,
    AppRoutePaths.patientLabResults,
    AppRoutePaths.patientSettings,
  ];

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = navItems.where((n) => _bottomItems.contains(n.path)).toList();
    final currentIndex = bottomNavItems.indexWhere((n) => n.path == activeRoute).clamp(0, bottomNavItems.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFF080B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0B1E),
        elevation: 0,
        title: Text(title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white38),
            onPressed: () { auth.logout(); context.go(AppRoutePaths.roleSelect); },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF1A1540)),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(activeRoute), child: child),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0B1E),
          border: Border(top: BorderSide(color: Color(0xFF1A1540))),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: accent,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
          onTap: (i) => context.go(bottomNavItems[i].path),
          items: bottomNavItems.map((item) => BottomNavigationBarItem(
            icon: Icon(item.icon, size: 22),
            label: item.label,
          )).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  const _NavItem({required this.label, required this.icon, required this.path});
}
