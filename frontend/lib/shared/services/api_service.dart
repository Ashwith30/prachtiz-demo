import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Centralised HTTP client for the Prachtiz API.
class ApiService {
  // Local dev — Flutter Web runs on its own port so we target the backend directly.
  static const String _baseUrl = 'http://localhost:3000/api';

  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String? _token;

  void setToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── GET ────────────────────────────────────────────────────────────────────
  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final res = await http.get(uri, headers: _headers);
    return _parse(res);
  }

  // ── POST ───────────────────────────────────────────────────────────────────
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    final res = await http.post(uri, headers: _headers, body: jsonEncode(body));
    return _parse(res);
  }

  // ── PATCH ──────────────────────────────────────────────────────────────────
  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    final res = await http.patch(uri, headers: _headers, body: jsonEncode(body));
    return _parse(res);
  }

  // ── Response parser ────────────────────────────────────────────────────────
  dynamic _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final errMsg = body['error'] ?? 'Unknown error (${res.statusCode})';
    throw ApiException(errMsg, res.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
