import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/services/auth_service.dart';
import '../../app/navigation/app_route_paths.dart';

class ReceptionistShell extends StatefulWidget {
  final Widget child;
  final String activeRoute;

  const ReceptionistShell({
    super.key,
    required this.child,
    required this.activeRoute,
  });

  @override
  State<ReceptionistShell> createState() => _ReceptionistShellState();
}

class _ReceptionistShellState extends State<ReceptionistShell> {
  bool? _manuallyCollapsed;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _navItems = [
    _NavItem(label: 'Dashboard',   icon: Icons.dashboard_outlined,    path: AppRoutePaths.receptionistDashboard),
    _NavItem(label: 'Appointments',icon: Icons.calendar_month_outlined,path: AppRoutePaths.receptionistDashboard), // reuse appointments section
    _NavItem(label: 'Patients',    icon: Icons.people_outline,         path: AppRoutePaths.receptionistPatients),
    _NavItem(label: 'Billing',     icon: Icons.receipt_outlined,       path: AppRoutePaths.receptionistBilling),
    _NavItem(label: 'Tasks',       icon: Icons.task_alt_outlined,      path: AppRoutePaths.receptionistTasks),
    _NavItem(label: 'Schedule',    icon: Icons.event_note_outlined,    path: AppRoutePaths.receptionistSchedule),
    _NavItem(label: 'Settings',    icon: Icons.settings_outlined,      path: AppRoutePaths.receptionistSettings),
  ];

  static const Color _sidebarBg   = Color(0xFF0B1A2C);
  static const Color _sidebarBorder = Color(0xFF1A2E44);
  static const Color _accent       = Color(0xFF24C06F); // Receptionist green

  String _titleForRoute(String r) {
    switch (r) {
      case AppRoutePaths.receptionistDashboard: return 'Reception Dashboard';
      case AppRoutePaths.receptionistPatients:  return 'Patient Registry';
      case AppRoutePaths.receptionistBilling:   return 'Billing & Invoices';
      case AppRoutePaths.receptionistTasks:     return 'Task Board';
      case AppRoutePaths.receptionistSchedule:  return 'Doctor Schedule';
      case AppRoutePaths.receptionistSettings:  return 'Settings';
      default: return 'Reception';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    final bool isMobile = w < 600;
    final bool isCollapsed = _manuallyCollapsed ?? (w < 1200);
    final String title = _titleForRoute(widget.activeRoute);
    final auth = AuthService.instance;

    Widget sidebar = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: isCollapsed ? 64 : 220,
      decoration: const BoxDecoration(
        color: _sidebarBg,
        border: Border(right: BorderSide(color: _sidebarBorder, width: 1)),
      ),
      child: Column(
        children: [
          // Logo area
          Container(
            height: 60,
            alignment: Alignment.center,
            child: isCollapsed
                ? const Icon(Icons.support_agent_rounded, color: _accent, size: 24)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.support_agent_rounded, color: _accent, size: 20),
                      const SizedBox(width: 8),
                      Text('Reception', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
          ),
          const Divider(color: _sidebarBorder, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _navItems.map((item) {
                final isActive = widget.activeRoute == item.path;
                return Tooltip(
                  message: isCollapsed ? item.label : '',
                  child: InkWell(
                    onTap: () => context.go(item.path),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? _accent.withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Icon(item.icon, size: 20,
                            color: isActive ? _accent : Colors.white.withOpacity(0.45)),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 10),
                            Text(item.label,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                color: isActive ? _accent : Colors.white.withOpacity(0.65),
                              )),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // User + logout
          const Divider(color: _sidebarBorder, height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: isCollapsed
                ? IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white38, size: 20),
                    onPressed: () { auth.logout(); context.go(AppRoutePaths.roleSelect); },
                  )
                : Row(
                    children: [
                      CircleAvatar(radius: 16, backgroundColor: _accent.withOpacity(0.15),
                        child: Text(auth.session?.initials ?? 'R',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _accent))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(auth.session?.fullName ?? 'Receptionist',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                          Text('Receptionist', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                        ]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white38, size: 18),
                        onPressed: () { auth.logout(); context.go(AppRoutePaths.roleSelect); },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF060C1A),
      drawer: isMobile ? Drawer(child: sidebar) : null,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1226),
        elevation: 0,
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white70),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : IconButton(
                icon: Icon(isCollapsed ? Icons.menu_open_rounded : Icons.menu_rounded, color: Colors.white70),
                onPressed: () => setState(() => _manuallyCollapsed = !isCollapsed),
              ),
        title: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _accent.withOpacity(0.15),
              child: Text(auth.session?.initials ?? 'R',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _accent)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _sidebarBorder),
        ),
      ),
      body: Row(
        children: [
          if (!isMobile) sidebar,
          Expanded(
            child: widget.child,
          ),
        ],
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
