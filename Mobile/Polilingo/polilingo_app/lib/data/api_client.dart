import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl =
      'http://localhost:8000'; // Update for mobile testing if needed

  String? _token;
  Future<bool> Function()? onTokenExpired;

  ApiClient() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<http.Response> get(String endpoint, {bool useRefresh = true}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    if (useRefresh &&
        (response.statusCode == 401 || response.statusCode == 403) &&
        onTokenExpired != null) {
      final refreshed = await onTokenExpired!();
      if (refreshed) {
        // Retry once with new token
        return http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers);
      }
    }

    return response;
  }

  Future<http.Response> post(
    String endpoint, {
    dynamic body,
    bool useRefresh = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (useRefresh &&
        (response.statusCode == 401 || response.statusCode == 403) &&
        onTokenExpired != null) {
      final refreshed = await onTokenExpired!();
      if (refreshed) {
        // Retry once with new token
        return http.post(
          url,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }

    return response;
  }
}
