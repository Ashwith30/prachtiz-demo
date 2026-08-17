import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../icons/app_icons.dart';

class AppSidebarFooter extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const AppSidebarFooter({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  State<AppSidebarFooter> createState() => _AppSidebarFooterState();
}

class _AppSidebarFooterState extends State<AppSidebarFooter> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool collapsed = widget.isCollapsed;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Semantics(
        button: true,
        label: collapsed ? 'Expand navigation menu' : 'Collapse navigation menu',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit:  (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 36,
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 0 : 10,
              ),
              decoration: BoxDecoration(
                color: _hovered
                    ? Colors.white.withOpacity(0.06)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  AnimatedRotation(
                    turns: collapsed ? 0.0 : 0.5,       // icon flips direction
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      AppIcons.collapseLeft,
                      color: _hovered
                          ? Colors.white
                          : const Color(0xFF64748B),
                      size: 16,
                    ),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: collapsed ? 0 : 1,
                        duration: const Duration(milliseconds: 160),
                        child: Text(
                          "Collapse Menu",
                          style: GoogleFonts.inter(
                            color: _hovered
                                ? Colors.white
                                : const Color(0xFF8DA4C0),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
