import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kGreen = Color(0xFF24C06F);
const _kGreenTint = Color(0x1A24C06F); // green at 10% opacity
const _kLabel = Color(0xFFCBD5E1);
const _kHover = Color(0x0AFFFFFF); // white at ~4%

class AppSidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final String? badge;
  final VoidCallback onTap;

  const AppSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCollapsed,
    this.badge,
    required this.onTap,
  });

  @override
  State<AppSidebarItem> createState() => _AppSidebarItemState();
}

class _AppSidebarItemState extends State<AppSidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isActive;
    final bool collapsed = widget.isCollapsed;

    final Color iconColor =
        active ? _kGreen : (_hovered ? Colors.white : const Color(0xFF8DA4C0));
    final Color labelColor =
        active ? _kGreen : (_hovered ? Colors.white : _kLabel);
    final Color bgColor =
        active ? _kGreenTint : (_hovered ? _kHover : Colors.transparent);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: 38,
      margin: EdgeInsets.symmetric(
        horizontal: collapsed ? 8 : 10,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        // Active: subtle green left-side accent bar rendered via a Stack
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // ── Active left accent bar ─────────────────────────────────────────
          if (active)
            Positioned(
              left: 0,
              top: 6,
              bottom: 6,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: _kGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          if (collapsed && widget.badge != null)
            Positioned(
              top: 6,
              right: 8,
              child: Container(
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _kGreen,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xFF13294B), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

          // ── Row: icon + animated label + badge ────────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  AnimatedScale(
                    scale: active ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(widget.icon, size: 17, color: iconColor),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 11),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 160),
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                            color: labelColor,
                            height: 1.0,
                          ),
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  if (widget.badge != null)
                    AnimatedOpacity(
                      opacity: collapsed ? 0 : 1,
                      duration: const Duration(milliseconds: 160),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Tooltip in collapsed mode
    if (collapsed) {
      content = Tooltip(
        message: widget.label,
        preferBelow: false,
        child: content,
      );
    }

    return Semantics(
      button: true,
      selected: active,
      label:
          '${widget.label}${widget.badge != null ? " (${widget.badge} items)" : ""}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onTap,
            child: content,
          ),
        ),
      ),
    );
  }
}
