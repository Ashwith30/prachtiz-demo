import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../app/navigation/app_route_paths.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/constants/app_assets.dart';
import '../../icons/app_icons.dart';
import '../app_searchbar.dart';
import 'live_pulse_badge.dart';
import 'availability_dropdown.dart';
import 'notification_button.dart';
import 'profile_widget.dart';
import '../../services/settings_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
const _kGreen = Color(0xFF24C06F);
const _kSlate = Color(0xFF94A3B8);

class AppNotification {
  final String id;
  final String category;
  final String text;
  final String time;
  final bool urgent;
  bool isRead;

  AppNotification({
    required this.id,
    required this.category,
    required this.text,
    required this.time,
    required this.urgent,
    this.isRead = false,
  });
}

class AppTopbar extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final String pageTitle;

  /// Whether the sidebar is currently collapsed.
  /// Used to animate the logo panel width in sync with the sidebar.
  final bool isCollapsed;

  /// Called when the user taps the logo area to toggle sidebar.
  final VoidCallback? onLogoAreaTap;

  const AppTopbar({
    super.key,
    this.onMenuPressed,
    required this.pageTitle,
    this.isCollapsed = false,
    this.onLogoAreaTap,
  });

  @override
  State<AppTopbar> createState() => _AppTopbarState();
}

class _AppTopbarState extends State<AppTopbar> {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      category: 'CRITICAL ALERT',
      text: 'Marcus Vance (PT-0482) BP exceeds systolic threshold: 142/90.',
      time: '2m ago',
      urgent: true,
    ),
    AppNotification(
      id: '2',
      category: 'Telehealth Consultation',
      text: 'Incoming video request from Sarah Connor.',
      time: '15m ago',
      urgent: false,
    ),
    AppNotification(
      id: '3',
      category: 'Laboratory Report',
      text: 'Biochemical Blood Panel results uploaded successfully.',
      time: '1h ago',
      urgent: false,
    ),
    AppNotification(
      id: '4',
      category: 'EMR Encrypted backup',
      text: 'Daily schedule archive uploaded to vault.',
      time: '3h ago',
      urgent: false,
    ),
    AppNotification(
      id: '5',
      category: 'System Update',
      text: 'EMR database signature keys rotated.',
      time: '1d ago',
      urgent: false,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth < 1100 && !isMobile;

    return FocusTraversalGroup(
      child: Container(
        height: AppDimensions.topbarHeight,
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left: Unified Logo Panel ────────────────────────────────────
            if (!isMobile)
              _LogoPanel(
                isCollapsed: widget.isCollapsed,
                onTap: widget.onLogoAreaTap,
              ),

            // ── Right Area: Contains actions and mobile header ──────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF1E3A8A), // Royal blue bottom border
                      width: 3.5,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Mobile: Hamburger + Logo ────────────────────────────────────
                    if (isMobile) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(AppIcons.menu, color: Color(0xFF1E293B)),
                        onPressed: widget.onMenuPressed,
                        tooltip: 'Open menu drawer',
                      ),
                      const SizedBox(width: 8),
                      _InlineMobileLogo(),
                    ],

                    // ── Desktop/Tablet Actions ─────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14.0 : 24.0),
                        child: isMobile
                            ? const _MobileActions()
                            : isTablet
                                ? _TabletActions(
                                    badgeCount: _unreadCount,
                                    onNotificationPressed: () => _showNotificationsOverlay(context),
                                  )
                                : _DesktopActions(
                                    badgeCount: _unreadCount,
                                    onNotificationPressed: () => _showNotificationsOverlay(context),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              alignment: Alignment.topRight,
              backgroundColor: const Color(0xFF0C0E1F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active_outlined, color: _kGreen, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Notifications & Alerts${_unreadCount > 0 ? " ($_unreadCount)" : ""}',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 8),
                    if (_notifications.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                for (var n in _notifications) {
                                  n.isRead = true;
                                }
                              });
                              setState(() {});
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Mark all read',
                              style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                _notifications.clear();
                              });
                              setState(() {});
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Clear all',
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (_notifications.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.notifications_off_outlined, color: Colors.white30, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                'No new notifications',
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(_notifications.length, (index) {
                              final notification = _notifications[index];
                              return _buildNotificationItem(
                                notification,
                                onMarkRead: () {
                                  setDialogState(() {
                                    notification.isRead = true;
                                  });
                                  setState(() {});
                                },
                                onClear: () {
                                  setDialogState(() {
                                    _notifications.removeAt(index);
                                  });
                                  setState(() {});
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(
    AppNotification notification, {
    required VoidCallback onMarkRead,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.white24
                  : (notification.urgent ? const Color(0xFFEF4444) : _kGreen),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.category,
                      style: GoogleFonts.inter(
                        color: notification.isRead
                            ? Colors.white38
                            : (notification.urgent ? Color(0xFFEF4444) : AppColors.primary),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      notification.time,
                      style: GoogleFonts.inter(color: _kSlate, fontSize: 8.5),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notification.text,
                  style: GoogleFonts.inter(
                    color: notification.isRead
                        ? Colors.white38
                        : Colors.white.withOpacity(0.85),
                    fontSize: 11,
                    height: 1.35,
                    decoration: notification.isRead ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!notification.isRead)
                IconButton(
                  icon: const Icon(Icons.done, size: 14, color: Colors.white70),
                  tooltip: 'Mark read',
                  onPressed: onMarkRead,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.close, size: 14, color: Colors.white38),
                tooltip: 'Clear',
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo Panel — left section of the topbar, merges with the sidebar visually
// ─────────────────────────────────────────────────────────────────────────────
class _LogoPanel extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback? onTap;

  const _LogoPanel({required this.isCollapsed, this.onTap});

  @override
  Widget build(BuildContext context) {
    final double panelWidth = isCollapsed
        ? AppDimensions.sidebarCollapsedWidth
        : AppDimensions.sidebarWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: panelWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF13294B), Color(0xFF5D6E8C)],
        ),
        border: Border(
          right: BorderSide(color: Color(0xFF1E293B), width: 1.0),
          bottom: BorderSide(
            color: Color(0xFF24C06F), // Bright green line under the logo panel
            width: 3.5,
          ),
        ),
      ),
      child: MouseRegion(
        cursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 10 : 18,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale:
                      Tween<double>(begin: 0.94, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
              child: isCollapsed
                  ? const _CollapsedLogo(key: ValueKey('collapsed'))
                  : const _ExpandedLogo(key: ValueKey('expanded')),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Expanded: full PraCHtiz logo ─────────────────────────────────────────────
class _ExpandedLogo extends StatelessWidget {
  const _ExpandedLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Image.asset(
          AppAssets.logoClinical,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => const _PraCHtizText(),
        ),
      ),
    );
  }
}

// ── Collapsed: dedicated CallHealth logo ────────────────────────────────────
class _CollapsedLogo extends StatelessWidget {
  const _CollapsedLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: Image.asset(
          AppAssets.logoCallHealth,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _kGreen.withOpacity(0.12),
              border: Border.all(color: _kGreen.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              'CH',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Text fallback when image fails to load ────────────────────────────────────
class _PraCHtizText extends StatelessWidget {
  const _PraCHtizText();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('Pra',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0)),
            Text('CH',
                style: GoogleFonts.poppins(
                    color: _kGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0)),
            Text('tiz',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0)),
          ],
        ),
        Text(
          'A Product by CallHealth',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 6.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

// ── Mobile inline logo (shown after hamburger on mobile) ──────────────────────
class _InlineMobileLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Image.asset(
        AppAssets.logoClinical,
        width: 100,
        height: 28,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('Pra',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF13294B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0)),
            Text('CH',
                style: GoogleFonts.poppins(
                    color: _kGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0)),
            Text('tiz',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF13294B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action areas (Desktop / Tablet / Mobile)
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopActions extends StatelessWidget {
  final int badgeCount;
  final VoidCallback onNotificationPressed;

  const _DesktopActions({
    required this.badgeCount,
    required this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsManager.instance,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppSearchBar(width: 320, height: 40),
            const Spacer(),
            const _PresencePill(),
            const SizedBox(width: 16),
            const LivePulseBadge(activeCases: 8),
            const SizedBox(width: 16),
            const AvailabilityDropdown(),
            const SizedBox(width: 16),
            NotificationButton(
              icon: Icons.notifications_none_outlined,
              badgeCount: badgeCount,
              badgeColor: const Color(0xFF24C06F),
              tooltip: 'View alerts',
              onPressed: onNotificationPressed,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: _kSlate),
              onPressed: () => context.go(AppRoutePaths.settings),
              tooltip: 'Settings',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8.0),
            ),
            const SizedBox(width: 16),
            ProfileWidget(
              initials: SettingsManager.instance.initials,
              name: SettingsManager.instance.fullName,
              role: SettingsManager.instance.specialty,
              imageBytes: SettingsManager.instance.profilePhotoBytes,
              onTap: () => _showProfileOverlay(context),
            ),
          ],
        );
      },
    );
  }
}

class _TabletActions extends StatelessWidget {
  final int badgeCount;
  final VoidCallback onNotificationPressed;

  const _TabletActions({
    required this.badgeCount,
    required this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsManager.instance,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppSearchBar(width: 320, height: 40),
              ),
            ),
            const SizedBox(width: 12),
            NotificationButton(
              icon: Icons.notifications_none_outlined,
              badgeCount: badgeCount,
              badgeColor: const Color(0xFF24C06F),
              tooltip: 'View alerts',
              onPressed: onNotificationPressed,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: _kSlate, size: 20),
              onPressed: () => context.go(AppRoutePaths.settings),
              tooltip: 'Settings',
            ),
            const SizedBox(width: 16),
            ProfileWidget(
              initials: SettingsManager.instance.initials,
              name: SettingsManager.instance.fullName,
              role: SettingsManager.instance.specialty,
              imageBytes: SettingsManager.instance.profilePhotoBytes,
              onTap: () => _showProfileOverlay(context),
            ),
          ],
        );
      },
    );
  }
}

class _MobileActions extends StatelessWidget {
  const _MobileActions();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsManager.instance,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: _kSlate, size: 20),
              onPressed: () => _showMobileSearch(context),
              tooltip: 'Search',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8.0),
            ),
            const SizedBox(width: 8),
            ProfileWidget(
              initials: SettingsManager.instance.initials,
              name: SettingsManager.instance.fullName,
              role: SettingsManager.instance.specialty,
              imageBytes: SettingsManager.instance.profilePhotoBytes,
              onTap: () => _showProfileOverlay(context),
            ),
          ],
        );
      },
    );
  }

  void _showMobileSearch(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF13294B),
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: AppSearchBar(width: double.infinity, height: 44),
          ),
        );
      },
    );
  }
}



void _showProfileOverlay(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        alignment: Alignment.topRight,
        backgroundColor: const Color(0xFF0C0E1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: _kGreen.withOpacity(0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(SettingsManager.instance.initials, style: GoogleFonts.inter(color: _kGreen, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(SettingsManager.instance.fullName, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(SettingsManager.instance.specialty, style: GoogleFonts.inter(color: _kSlate, fontSize: 10.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 10),
              _buildProfileOption(context, Icons.person_outline, 'My Profile Settings', () {
                Navigator.of(context).pop();
                context.go(AppRoutePaths.settings);
              }),
              _buildProfileOption(context, Icons.security_outlined, 'EMR Crypto Key Lock', () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: const Color(0xFF0C0E1F), content: Text('Session encrypted key: SHA256_ACTIVE', style: GoogleFonts.inter(color: Colors.white))),
                );
              }),
              _buildProfileOption(context, Icons.circle, 'Status: Available', () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: const Color(0xFF0C0E1F), content: Text('Availability status toggled to Active', style: GoogleFonts.inter(color: Colors.white))),
                );
              }, iconColor: _kGreen),
              const SizedBox(height: 6),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 6),
              _buildProfileOption(context, Icons.logout_outlined, 'Logout / Lock Session', () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: const Color(0xFF0C0E1F), content: Text('EMR clinic dashboard locked.', style: GoogleFonts.inter(color: Colors.white))),
                );
              }, iconColor: const Color(0xFFEF4444), textColor: const Color(0xFFEF4444)),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildProfileOption(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? iconColor, Color? textColor}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? _kSlate),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.inter(color: textColor ?? Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Presence Pill — "who's in now"
// ─────────────────────────────────────────────────────────────────────────────
class _PresencePill extends StatelessWidget {
  const _PresencePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF13294B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Text(
            'Maria Santos',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'in now',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF60A5FA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
