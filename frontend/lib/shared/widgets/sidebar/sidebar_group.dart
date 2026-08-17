import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSidebarGroup extends StatelessWidget {
  final String title;
  final bool isCollapsed;
  final Widget child;

  const AppSidebarGroup({
    super.key,
    required this.title,
    required this.isCollapsed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label — fades out when collapsed, replaced by a thin divider
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: isCollapsed
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 18, left: 20, bottom: 6),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8DA4C0),
                letterSpacing: 0,
              ),
            ),
          ),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
