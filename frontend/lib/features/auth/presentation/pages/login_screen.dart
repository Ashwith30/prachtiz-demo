import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../app/navigation/app_route_paths.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  late _RoleStyle _style;

  @override
  void initState() {
    super.initState();
    _style = _RoleStyle.of(widget.role);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = AuthService.instance;
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text.trim(), widget.role);
    if (!mounted) return;
    if (ok) {
      // Route based on role
      switch (widget.role) {
        case UserRole.doctor:       context.go(AppRoutePaths.dashboard); break;
        case UserRole.receptionist: context.go(AppRoutePaths.receptionistDashboard); break;
        case UserRole.patient:      context.go(AppRoutePaths.patientHome); break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1F),
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [_style.color.withOpacity(0.12), Colors.transparent]),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.go(AppRoutePaths.roleSelect),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(width: 6),
                            Text('Back', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _style.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _style.color.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_style.icon, size: 14, color: _style.color),
                            const SizedBox(width: 6),
                            Text(
                              _style.label.toUpperCase(),
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _style.color, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Welcome back',
                        style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to your ${_style.label} account',
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.45)),
                      ),
                      const SizedBox(height: 36),

                      // Form
                      ListenableBuilder(
                        listenable: AuthService.instance,
                        builder: (context, _) {
                          final auth = AuthService.instance;
                          return Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildField(
                                  controller: _emailCtrl,
                                  label: 'Email address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildField(
                                  controller: _passCtrl,
                                  label: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscure,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      size: 18, color: Colors.white38),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                  validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                                ),
                                const SizedBox(height: 10),

                                // Error message
                                if (auth.error != null)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                                    ),
                                    child: Text(auth.error!, style: GoogleFonts.inter(fontSize: 13, color: Colors.red.shade300)),
                                  ),

                                const SizedBox(height: 16),

                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: auth.loading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _style.color,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: auth.loading
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text('Sign In', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Sign up link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Don't have an account? ", style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
                                    GestureDetector(
                                      onTap: () => context.go(AppRoutePaths.signupPath(widget.role.name)),
                                      child: Text(
                                        'Sign Up',
                                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _style.color),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.05),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
        prefixIcon: Icon(icon, size: 18, color: Colors.white38),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0E1535),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _style.color, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

class _RoleStyle {
  final Color color;
  final IconData icon;
  final String label;

  const _RoleStyle({required this.color, required this.icon, required this.label});

  static _RoleStyle of(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return const _RoleStyle(color: Color(0xFF3F8CFF), icon: Icons.medical_services_outlined, label: 'Doctor');
      case UserRole.receptionist:
        return const _RoleStyle(color: Color(0xFF24C06F), icon: Icons.support_agent_outlined, label: 'Receptionist');
      case UserRole.patient:
        return const _RoleStyle(color: Color(0xFF8B5CF6), icon: Icons.person_outlined, label: 'Patient');
    }
  }
}
