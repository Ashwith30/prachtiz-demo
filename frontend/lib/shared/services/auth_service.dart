import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'settings_manager.dart';

enum UserRole { doctor, receptionist, patient }

class UserSession {
  final String id;
  final String token;
  final UserRole role;
  final String email;
  final String firstName;
  final String lastName;
  final Map<String, dynamic> profile;

  const UserSession({
    required this.id,
    required this.token,
    required this.role,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profile,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  static UserRole _parseRole(String r) {
    switch (r) {
      case 'doctor':       return UserRole.doctor;
      case 'receptionist': return UserRole.receptionist;
      case 'patient':      return UserRole.patient;
      default:             return UserRole.patient;
    }
  }

  static UserSession fromApiResponse(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>;
    return UserSession(
      id: user['id'] as String,
      token: data['token'] as String,
      role: _parseRole(data['role'] as String),
      email: user['email'] as String,
      firstName: user['first_name'] as String,
      lastName: user['last_name'] as String,
      profile: user,
    );
  }
}

/// Manages login, signup, and the current session across the app.
class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  UserSession? _session;
  bool _loading = false;
  String? _error;

  UserSession? get session => _session;
  bool get isLoggedIn => _session != null;
  bool get loading => _loading;
  String? get error => _error;
  UserRole? get role => _session?.role;

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password, UserRole role) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.instance.post('/auth/login', {
        'email': email,
        'password': password,
        'role': _roleString(role),
      });
      _session = UserSession.fromApiResponse(data);
      ApiService.instance.setToken(_session!.token);
      if (_session!.role == UserRole.doctor) {
        SettingsManager.instance.updateProfile(
          firstName: _session!.firstName,
          lastName: _session!.lastName,
          email: _session!.email,
          phone: _session!.profile['phone'] ?? '',
          specialty: _session!.profile['specialty'] ?? '',
          license: _session!.profile['license'] ?? '',
        );
      }
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Is the server running?';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Signup ─────────────────────────────────────────────────────────────────
  Future<bool> signup(UserRole role, Map<String, dynamic> payload) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.instance.post('/auth/signup/${_roleString(role)}', payload);
      _session = UserSession.fromApiResponse(data);
      ApiService.instance.setToken(_session!.token);
      if (_session!.role == UserRole.doctor) {
        SettingsManager.instance.updateProfile(
          firstName: _session!.firstName,
          lastName: _session!.lastName,
          email: _session!.email,
          phone: _session!.profile['phone'] ?? '',
          specialty: _session!.profile['specialty'] ?? '',
          license: _session!.profile['license'] ?? '',
        );
      }
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Is the server running?';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Update Profile ──────────────────────────────────────────────────────────
  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    if (_session == null) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final roleStr = _roleString(_session!.role);
      final data = await ApiService.instance.patch('/$roleStr/profile', payload);
      
      _session = UserSession(
        id: _session!.id,
        token: _session!.token,
        role: _session!.role,
        email: data['email'] ?? _session!.email,
        firstName: data['first_name'] ?? _session!.firstName,
        lastName: data['last_name'] ?? _session!.lastName,
        profile: data,
      );

      if (_session!.role == UserRole.doctor) {
        SettingsManager.instance.updateProfile(
          firstName: _session!.firstName,
          lastName: _session!.lastName,
          email: _session!.email,
          phone: _session!.profile['phone'] ?? '',
          specialty: _session!.profile['specialty'] ?? '',
          license: _session!.profile['license'] ?? '',
        );
      }
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Failed to update profile settings';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  void logout() {
    _session = null;
    _error = null;
    ApiService.instance.setToken(null);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _roleString(UserRole r) {
    switch (r) {
      case UserRole.doctor:       return 'doctor';
      case UserRole.receptionist: return 'receptionist';
      case UserRole.patient:      return 'patient';
    }
  }
}
