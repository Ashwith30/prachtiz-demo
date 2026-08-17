import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../icons/app_icons.dart';
import '../../navigation/sidebar_item.dart';
import '../../../app/navigation/app_route_paths.dart';
import 'sidebar_item.dart';
import 'sidebar_group.dart';
import 'sidebar_footer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand colours (referenced locally for clarity)
// ─────────────────────────────────────────────────────────────────────────────
const _kDivider = Color(0xFF1E293B);

class AppSidebar extends StatefulWidget {
  final String activeRoute;
  final bool isCollapsed;
  final VoidCallback? onToggle;

  const AppSidebar({
    super.key,
    required this.activeRoute,
    this.isCollapsed = false,
    this.onToggle,
  });

  static const List<SidebarSection> _sections = [
    SidebarSection(
      title: 'OVERVIEW',
      items: [
        SidebarItem(label: 'Dashboard',       icon: AppIcons.dashboard,       path: AppRoutePaths.dashboard),
        SidebarItem(label: 'Analytics',       icon: AppIcons.analytics,       path: AppRoutePaths.analytics),
        SidebarItem(label: 'Patient Overview',icon: AppIcons.patientOverview, path: AppRoutePaths.patientOverview),
      ],
    ),
    SidebarSection(
      title: 'CLINICAL SERVICES',
      items: [
        SidebarItem(label: 'Appointments',  icon: AppIcons.appointments,  path: AppRoutePaths.appointments, badge: '8'),
        SidebarItem(label: 'Health Records',icon: AppIcons.healthRecords,  path: AppRoutePaths.healthRecords),
        SidebarItem(label: 'Prescriptions', icon: AppIcons.prescriptions,  path: AppRoutePaths.prescriptions),
        SidebarItem(label: 'Lab Results',   icon: AppIcons.labResults,     path: AppRoutePaths.labResults),
        SidebarItem(label: 'Vaccinations',  icon: AppIcons.vaccinations,   path: AppRoutePaths.vaccinations),
        SidebarItem(label: 'Telemedicine',  icon: AppIcons.telemedicine,   path: AppRoutePaths.telemedicine),
        SidebarItem(label: 'Consultation',  icon: AppIcons.consultation,   path: AppRoutePaths.consultation),
      ],
    ),
    SidebarSection(
      title: 'MANAGEMENT',
      items: [
        SidebarItem(label: 'Staff',          icon: AppIcons.staff,          path: AppRoutePaths.staff),
        SidebarItem(label: 'Task Board',     icon: AppIcons.tasks,          path: AppRoutePaths.tasks),
        SidebarItem(label: 'Vitals Monitor', icon: AppIcons.vitals,         path: AppRoutePaths.vitals),
        SidebarItem(label: 'Patients List',  icon: AppIcons.patients,       path: AppRoutePaths.patients),
        SidebarItem(label: 'Doctor Schedule',icon: AppIcons.doctorSchedule, path: AppRoutePaths.doctorSchedule),
      ],
    ),
    SidebarSection(
      title: 'SYSTEMS & ADMIN',
      items: [
        SidebarItem(label: 'Billing',  icon: AppIcons.billing,  path: AppRoutePaths.billing),
        SidebarItem(label: 'Invoices', icon: AppIcons.invoices,  path: AppRoutePaths.invoices),
        SidebarItem(label: 'Services', icon: AppIcons.services,  path: AppRoutePaths.services),
        SidebarItem(label: 'Settings', icon: AppIcons.settings,  path: AppRoutePaths.settings),
      ],
    ),
  ];

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late final ScrollController _scrollController;
  late final Map<String, GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _itemKeys = {
      for (final section in AppSidebar._sections)
        for (final item in section.items) item.path: GlobalKey()
    };
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActiveItem());
  }

  @override
  void didUpdateWidget(covariant AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeRoute != oldWidget.activeRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActiveItem());
    }
  }

  void _scrollToActiveItem() {
    final activeKey = _itemKeys[widget.activeRoute];
    final context = activeKey?.currentContext;
    if (context == null || !mounted) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.35,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCollapsed = widget.isCollapsed;
    final double width =
        isCollapsed ? AppDimensions.sidebarCollapsedWidth : AppDimensions.sidebarWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: width,
      // Sidebar fills the remaining height below the shared topbar
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: _kDivider, width: 1.0),
        ),
      ),
      child: FocusTraversalGroup(
        child: Column(
          children: [
            // ── 1. Scrollable nav list — starts immediately (no logo here) ───
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: AppSidebar._sections.length,
                itemBuilder: (context, index) {
                  final section = AppSidebar._sections[index];
                  return AppSidebarGroup(
                    title: section.title,
                    isCollapsed: isCollapsed,
                    child: Column(
                      children: section.items.map((item) {
                        final bool isActive = widget.activeRoute == item.path;
                        return AppSidebarItem(
                          key: _itemKeys[item.path],
                          icon: item.icon,
                          label: item.label,
                          isActive: isActive,
                          isCollapsed: isCollapsed,
                          badge: item.badge,
                          onTap: () {
                            context.go(item.path);
                            final scaffoldState = Scaffold.maybeOf(context);
                            if (scaffoldState?.isDrawerOpen ?? false) {
                              scaffoldState?.closeDrawer();
                            }
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            // ── 2. Collapse toggle footer ─────────────────────────────────────
            if (widget.onToggle != null)
              AppSidebarFooter(
                isCollapsed: isCollapsed,
                onToggle: widget.onToggle!,
              ),
          ],
        ),
      ),
    );
  }
}
