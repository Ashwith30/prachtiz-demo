import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'dart:typed_data';

class SettingsManager extends ChangeNotifier {
  static final SettingsManager instance = SettingsManager._internal();
  SettingsManager._internal();

  // Profile Fields
  String _firstName = "Amanulla";
  String _lastName = "Baig";
  String _email = "dr.amanulla@prachtiz.com";
  String _phone = "+91 98765 43210";
  String _specialty = "General Physician";
  String _license = "MCI-123456";
  Uint8List? _profilePhotoBytes;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get phone => _phone;
  String get specialty => _specialty;
  String get license => _license;
  Uint8List? get profilePhotoBytes => _profilePhotoBytes;

  String get fullName => "Dr. $_firstName $_lastName";
  String get initials {
    String firstLetter = _firstName.isNotEmpty ? _firstName[0] : "";
    String lastLetter = _lastName.isNotEmpty ? _lastName[0] : "";
    return (firstLetter + lastLetter).toUpperCase();
  }

  // Notifications Fields
  bool smsAlerts = true;
  bool whatsAppAlerts = true;
  bool emailReports = false;
  bool securityAlerts = true;

  // Appearance Fields
  String _themeMode = "Dark"; // "Dark", "Light", "System"
  int _selectedAccentIndex = 0; // 0: Blue, 1: Purple, 2: Green, 3: Orange
  bool _compactMode = false;

  String get themeMode => _themeMode;
  int get selectedAccentIndex => _selectedAccentIndex;
  bool get compactMode => _compactMode;

  final List<Color> accentColors = [
    Color(0xFF3F8CFF), // Indigo/Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFF24C06F), // Emerald/Green
    Color(0xFFF59E0B), // Amber/Orange
  ];

  Color get activeAccentColor => accentColors[_selectedAccentIndex];

  void updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String specialty,
    required String license,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _phone = phone;
    _specialty = specialty;
    _license = license;
    notifyListeners();
  }

  void updateProfilePhoto(Uint8List bytes) {
    _profilePhotoBytes = bytes;
    notifyListeners();
  }

  void removeProfilePhoto() {
    _profilePhotoBytes = null;
    notifyListeners();
  }

  void updateNotifications({
    required bool smsAlerts,
    required bool whatsAppAlerts,
    required bool emailReports,
    required bool securityAlerts,
  }) {
    this.smsAlerts = smsAlerts;
    this.whatsAppAlerts = whatsAppAlerts;
    this.emailReports = emailReports;
    this.securityAlerts = securityAlerts;
    notifyListeners();
  }

  void updateTheme(String theme) {
    _themeMode = theme;
    notifyListeners();
  }

  void updateAccentIndex(int index) {
    _selectedAccentIndex = index;
    notifyListeners();
  }

  void updateCompactMode(bool compact) {
    _compactMode = compact;
    notifyListeners();
  }
}
