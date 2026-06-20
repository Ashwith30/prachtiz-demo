import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';
import '../../../../shared/services/settings_manager.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/app_avatar.dart';
class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    "Profile",
    "Notifications",
    "Security",
    "Appearance",
  ];

  final List<IconData> _tabIcons = [
    Icons.person_outline,
    Icons.notifications_none_outlined,
    Icons.shield_outlined,
    Icons.color_lens_outlined,
  ];

  // Profile Form Controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _licenseController;

  // Notifications State
  late bool _notifSmsAlerts;
  late bool _notifWhatsAppAlerts;
  late bool _notifEmailReports;
  late bool _notifSecurityAlerts;

  // Security State
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _twoFactorEnabled = false;

  // Active Sessions Mock Data
  final List<Map<String, dynamic>> _activeSessions = [
    {
      "device": "Chrome on macOS",
      "ip": "192.168.1.45",
      "location": "Bengaluru, India",
      "isActive": true,
      "time": "Active now",
    },
    {
      "device": "Safari on iPhone 15 Pro",
      "ip": "192.168.1.102",
      "location": "Bengaluru, India",
      "isActive": false,
      "time": "2 hours ago",
    },
  ];

  // Appearance State
  late String _selectedTheme;
  late int _selectedAccentIndex; // 0: Blue, 1: Purple, 2: Green, 3: Orange
  late bool _compactMode;

  @override
  void initState() {
    super.initState();
    final settings = SettingsManager.instance;
    _firstNameController = TextEditingController(text: settings.firstName);
    _lastNameController = TextEditingController(text: settings.lastName);
    _emailController = TextEditingController(text: settings.email);
    _phoneController = TextEditingController(text: settings.phone);
    _specialtyController = TextEditingController(text: settings.specialty);
    _licenseController = TextEditingController(text: settings.license);

    _notifSmsAlerts = settings.smsAlerts;
    _notifWhatsAppAlerts = settings.whatsAppAlerts;
    _notifEmailReports = settings.emailReports;
    _notifSecurityAlerts = settings.securityAlerts;

    _selectedTheme = settings.themeMode;
    _selectedAccentIndex = settings.selectedAccentIndex;
    _compactMode = settings.compactMode;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _licenseController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  final List<Color> _accentColors = [
    AppColors.primary, // Indigo/Blue
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF24C06F), // Emerald/Green
    const Color(0xFFF59E0B), // Amber/Orange
  ];

  final List<String> _accentNames = [
    "Indigo Blue",
    "Purple Haze",
    "Emerald Green",
    "Amber Glow",
  ];

  void _saveChanges() {
    SettingsManager.instance.updateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      specialty: _specialtyController.text,
      license: _licenseController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile settings saved successfully."),
        backgroundColor: Color(0xFF24C06F),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveNotifications() {
    SettingsManager.instance.updateNotifications(
      smsAlerts: _notifSmsAlerts,
      whatsAppAlerts: _notifWhatsAppAlerts,
      emailReports: _notifEmailReports,
      securityAlerts: _notifSecurityAlerts,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Notification rules updated successfully."),
        backgroundColor: Color(0xFF24C06F),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updatePassword() {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all password fields."),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New passwords do not match."),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password updated successfully."),
        backgroundColor: Color(0xFF24C06F),
        duration: Duration(seconds: 2),
      ),
    );
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _uploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        SettingsManager.instance.updateProfilePhoto(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Photo '${image.name}' uploaded successfully."),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Settings",
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  "Manage your account settings and preferences.",
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray600),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  // Mobile / Tablet Vertical Layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHorizontalTabs(),
                      const SizedBox(height: 24),
                      _buildContentArea(),
                    ],
                  );
                } else {
                  // Desktop Split Layout
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 240,
                        child: _buildVerticalTabs(),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _buildContentArea(),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _tabIcons[index],
                      size: 18,
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tabs[index],
                      style: GoogleFonts.inter(
                        color: isSelected ? AppColors.primary : Colors.grey,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVerticalTabs() {
    return Column(
      children: List.generate(_tabs.length, (index) {
        final isSelected = _selectedTabIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => setState(() => _selectedTabIndex = index),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _tabIcons[index],
                    size: 20,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _tabs[index],
                    style: GoogleFonts.inter(
                      color: isSelected ? AppColors.primary : Colors.grey,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContentArea() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildProfileTab();
      case 1:
        return _buildNotificationsTab();
      case 2:
        return _buildSecurityTab();
      case 3:
        return _buildAppearanceTab();
      default:
        return _buildProfileTab();
    }
  }

  Widget _buildProfileTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3042),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profile Information",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          // Avatar Section
          ListenableBuilder(
            listenable: SettingsManager.instance,
            builder: (context, _) {
              final hasPhoto = SettingsManager.instance.profilePhotoBytes != null;
              return Row(
                children: [
                  AppAvatar(
                    initials: SettingsManager.instance.initials,
                    imageBytes: SettingsManager.instance.profilePhotoBytes,
                    radius: 36.0,
                    backgroundColor: const Color(0xFF1E2548),
                    textColor: AppColors.primary,
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: _uploadPhoto,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              hasPhoto ? "Update Photo" : "Upload Photo",
                              style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (hasPhoto) ...[
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () {
                                SettingsManager.instance.removeProfilePhoto();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Profile photo removed."),
                                    backgroundColor: Colors.orangeAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: Text(
                                "Remove",
                                style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "JPG, PNG or GIF. Max 2MB.",
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 40),

          // Form Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              return Column(
                children: [
                  if (isSmall) ...[
                    _buildInputField("FIRST NAME", _firstNameController),
                    const SizedBox(height: 24),
                    _buildInputField("LAST NAME", _lastNameController),
                    const SizedBox(height: 24),
                    _buildInputField("EMAIL", _emailController),
                    const SizedBox(height: 24),
                    _buildInputField("PHONE", _phoneController),
                    const SizedBox(height: 24),
                    _buildInputField("SPECIALTY", _specialtyController),
                    const SizedBox(height: 24),
                    _buildInputField("LICENSE NO.", _licenseController),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(child: _buildInputField("FIRST NAME", _firstNameController)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildInputField("LAST NAME", _lastNameController)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildInputField("EMAIL", _emailController)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildInputField("PHONE", _phoneController)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildInputField("SPECIALTY", _specialtyController)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildInputField("LICENSE NO.", _licenseController)),
                      ],
                    ),
                  ]
                ],
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Action Buttons
          Row(
            children: [
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text("Save Changes", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Cancel", style: GoogleFonts.inter(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3042),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notification Settings",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Configure how and when you receive automated practice alerts.",
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 32),

          _buildToggleRow(
            title: "Enable Patient SMS Reminders",
            subtitle: "Send automated text alerts to patients 1 hour before their booking.",
            value: _notifSmsAlerts,
            onChanged: (val) => setState(() => _notifSmsAlerts = val),
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildToggleRow(
            title: "WhatsApp Booking Alerts",
            subtitle: "Send interactive check-in summaries via WhatsApp once a patient arrives.",
            value: _notifWhatsAppAlerts,
            onChanged: (val) => setState(() => _notifWhatsAppAlerts = val),
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildToggleRow(
            title: "Daily Revenue Email Digests",
            subtitle: "Receive a compiled sheet summarizing the day's financial checkouts.",
            value: _notifEmailReports,
            onChanged: (val) => setState(() => _notifEmailReports = val),
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildToggleRow(
            title: "Security & Log-in Alerts",
            subtitle: "Send an email alert immediately when a new device logs into this account.",
            value: _notifSecurityAlerts,
            onChanged: (val) => setState(() => _notifSecurityAlerts = val),
          ),

          const SizedBox(height: 40),
          Row(
            children: [
              ElevatedButton(
                onPressed: _saveNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text("Save Rules", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF24C06F),
          activeTrackColor: const Color(0xFF24C06F).withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildSecurityTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3042),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Security Preferences",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          // Two-Factor Auth Toggle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2548),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: AppColors.primary, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Two-Factor Authentication (2FA)",
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Add an extra layer of security by requiring verification codes.",
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _twoFactorEnabled,
                  onChanged: (val) {
                    setState(() => _twoFactorEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Two-Factor Authentication ${val ? 'enabled' : 'disabled'}."),
                        backgroundColor: val ? const Color(0xFF24C06F) : Colors.orangeAccent,
                      ),
                    );
                  },
                  activeColor: const Color(0xFF24C06F),
                  activeTrackColor: const Color(0xFF24C06F).withOpacity(0.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Password Change Section
          Text(
            "Change Password",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              return Column(
                children: [
                  _buildPasswordField("CURRENT PASSWORD", _currentPasswordController, _obscureCurrent, (val) {
                    setState(() => _obscureCurrent = val);
                  }),
                  const SizedBox(height: 20),
                  if (isSmall) ...[
                    _buildPasswordField("NEW PASSWORD", _newPasswordController, _obscureNew, (val) {
                      setState(() => _obscureNew = val);
                    }),
                    const SizedBox(height: 20),
                    _buildPasswordField("CONFIRM NEW PASSWORD", _confirmPasswordController, _obscureConfirm, (val) {
                      setState(() => _obscureConfirm = val);
                    }),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildPasswordField("NEW PASSWORD", _newPasswordController, _obscureNew, (val) {
                            setState(() => _obscureNew = val);
                          }),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildPasswordField("CONFIRM NEW PASSWORD", _confirmPasswordController, _obscureConfirm, (val) {
                            setState(() => _obscureConfirm = val);
                          }),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _updatePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text("Update Password", style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 40),

          // Active Sessions Mock
          Text(
            "Active Devices & Sessions",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            children: _activeSessions.map((session) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2548),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      session['device'].toString().contains("iPhone") ? Icons.phone_iphone : Icons.desktop_mac,
                      color: Colors.white54,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                session['device'].toString(),
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              if (session['isActive'] as bool) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF24C06F).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "Active",
                                    style: GoogleFonts.inter(color: const Color(0xFF24C06F), fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${session['ip']} • ${session['location']}",
                            style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      session['time'].toString(),
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, ValueChanged<bool> onToggleObscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E2548),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white38,
                size: 20,
              ),
              onPressed: () => onToggleObscure(!obscure),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3042),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Appearance Settings",
            style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          // Theme Selection Cards
          Text(
            "APPLICATION THEME",
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              final double cardWidth = isSmall ? double.infinity : (constraints.maxWidth - 32) / 3;
              
              Widget buildThemeCard(String themeName, IconData icon, String subtitle) {
                final isSelected = _selectedTheme == themeName;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedTheme = themeName);
                    SettingsManager.instance.updateTheme(themeName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$themeName mode activated.")),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2548),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.white10,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: isSelected ? AppColors.primary : Colors.white54, size: 24),
                        const SizedBox(height: 16),
                        Text(
                          themeName,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (isSmall) {
                return Column(
                  children: [
                    buildThemeCard("Dark", Icons.dark_mode_outlined, "Sleek glowing layout"),
                    const SizedBox(height: 12),
                    buildThemeCard("Light", Icons.light_mode_outlined, "Clean minimal styling"),
                    const SizedBox(height: 12),
                    buildThemeCard("System", Icons.settings_brightness_outlined, "Matches device settings"),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildThemeCard("Dark", Icons.dark_mode_outlined, "Sleek glowing layout"),
                    const SizedBox(width: 16),
                    buildThemeCard("Light", Icons.light_mode_outlined, "Clean minimal styling"),
                    const SizedBox(width: 16),
                    buildThemeCard("System", Icons.settings_brightness_outlined, "Matches device settings"),
                  ],
                );
              }
            },
          ),
          
          const SizedBox(height: 40),

          // Primary Accent Picker
          Text(
            "ACCENT COLOR",
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2548),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_accentColors.length, (index) {
                    final isSelected = _selectedAccentIndex == index;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedAccentIndex = index);
                        SettingsManager.instance.updateAccentIndex(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Accent theme set to ${_accentNames[index]}."),
                            backgroundColor: _accentColors[index],
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _accentColors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  _accentNames[_selectedAccentIndex],
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Density / Interface spacing
          Text(
            "INTERFACE SCALE",
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Compact Layout Density",
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Reduce margins and padding to show more information on single screens.",
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
            ),
            value: _compactMode,
            onChanged: (val) {
              setState(() => _compactMode = val);
              SettingsManager.instance.updateCompactMode(val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Compact layout ${val ? 'activated' : 'deactivated'}.")),
              );
            },
            activeColor: const Color(0xFF24C06F),
            activeTrackColor: const Color(0xFF24C06F).withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E2548),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
