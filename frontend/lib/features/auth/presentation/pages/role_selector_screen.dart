import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../app/navigation/app_route_paths.dart';

class RoleSelectorScreen extends StatefulWidget {
  const RoleSelectorScreen({super.key});

  @override
  State<RoleSelectorScreen> createState() => _RoleSelectorScreenState();
}

class _RoleSelectorScreenState extends State<RoleSelectorScreen> {
  UserRole? _hoveredRole;

  static const _roles = [
    _RoleCard(
      role: UserRole.doctor,
      title: 'Doctor',
      subtitle: 'Manage your clinic, patients\nand clinical records',
      icon: Icons.medical_services_outlined,
      gradient: [Color(0xFF3F8CFF), Color(0xFF1A56DB)],
      accentColor: Color(0xFF3F8CFF),
      tag: 'CLINICAL',
    ),
    _RoleCard(
      role: UserRole.receptionist,
      title: 'Receptionist',
      subtitle: 'Schedule appointments,\ncheck-in patients & billing',
      icon: Icons.support_agent_outlined,
      gradient: [Color(0xFF24C06F), Color(0xFF0D7A45)],
      accentColor: Color(0xFF24C06F),
      tag: 'FRONT DESK',
    ),
    _RoleCard(
      role: UserRole.patient,
      title: 'Patient',
      subtitle: 'View appointments, records\nand prescriptions',
      icon: Icons.person_outlined,
      gradient: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
      accentColor: Color(0xFF8B5CF6),
      tag: 'PORTAL',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1F),
      body: Stack(
        children: [
          // Background gradient orbs
          Positioned(
            top: -120, left: -120,
            child: _GlowOrb(color: const Color(0xFF3F8CFF).withOpacity(0.15), size: 500),
          ),
          Positioned(
            bottom: -100, right: -100,
            child: _GlowOrb(color: const Color(0xFF8B5CF6).withOpacity(0.12), size: 450),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo + Brand
                    _buildBrand().animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
                    const SizedBox(height: 48),

                    // Role cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        if (isWide) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: _roles.asMap().entries.map((e) =>
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: _buildRoleCard(e.value, e.key),
                              )
                            ).toList(),
                          );
                        }
                        return Column(
                          children: _roles.asMap().entries.map((e) =>
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildRoleCard(e.value, e.key, fullWidth: true),
                            )
                          ).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Bottom hint
                    Text(
                      'Select your role to continue',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3F8CFF), Color(0xFF1A56DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F8CFF).withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          'PraCHtiz',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Clinical Management System',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.45),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(_RoleCard card, int index, {bool fullWidth = false}) {
    final isHovered = _hoveredRole == card.role;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRole = card.role),
      onExit: (_) => setState(() => _hoveredRole = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(AppRoutePaths.loginPath(card.role.name)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: fullWidth ? double.infinity : 200,
          transform: isHovered
              ? (Matrix4.identity()..translate(0.0, -8.0))
              : Matrix4.identity(),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isHovered
                  ? LinearGradient(colors: card.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : LinearGradient(
                      colors: [const Color(0xFF0E1535), const Color(0xFF111A3D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHovered ? card.accentColor.withOpacity(0.6) : Colors.white.withOpacity(0.08),
                width: isHovered ? 1.5 : 1,
              ),
              boxShadow: isHovered
                  ? [BoxShadow(color: card.accentColor.withOpacity(0.3), blurRadius: 32, offset: const Offset(0, 8))]
                  : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                // Tag badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: card.accentColor.withOpacity(isHovered ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    card.tag,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isHovered ? Colors.white : card.accentColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Icon
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: isHovered ? Colors.white.withOpacity(0.2) : card.accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(card.icon, color: isHovered ? Colors.white : card.accentColor, size: 28),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  card.title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  card.subtitle,
                  textAlign: fullWidth ? TextAlign.left : TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: isHovered ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.45),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // CTA
                Row(
                  mainAxisAlignment: fullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isHovered ? Colors.white : card.accentColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded,
                      size: 16,
                      color: isHovered ? Colors.white : card.accentColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 150 + (index * 100)))
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}

class _RoleCard {
  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accentColor;
  final String tag;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.tag,
  });
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
