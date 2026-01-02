import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/api_client.dart';

enum AuthStatus { authenticated, unauthenticated, profileMissing, loading }

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  AuthStatus _status = AuthStatus.loading;
  Map<String, dynamic>? _userProfile;

  AuthStatus get status => _status;
  Map<String, dynamic>? get userProfile => _userProfile;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null) {
      await _apiClient.setToken(token);
      await checkProfile();
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['session']['access_token'];
        final refreshToken = data['session']['refresh_token'];

        await _apiClient.setToken(token);

        // Save refresh token as well
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('refresh_token', refreshToken);

        await checkProfile();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<bool> signup(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/auth/signup',
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('Signup failed: ${errorData['detail']}');
      }
    } catch (e) {
      debugPrint('Signup error: $e');
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> checkProfile() async {
    try {
      debugPrint('🔍 Checking profile...');
      final response = await _apiClient.get('/users/profile');
      debugPrint('📊 Profile check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        _userProfile = jsonDecode(response.body);
        _status = AuthStatus.authenticated;
        debugPrint('✅ Profile exists: ${_userProfile?['username']}');
      } else if (response.statusCode == 404) {
        _userProfile = null;
        _status = AuthStatus.profileMissing;
        debugPrint('❌ Profile missing - showing setup screen');
      } else {
        _userProfile = null;
        _status = AuthStatus.unauthenticated;
        debugPrint('⚠️ Unexpected status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Profile check error: $e');
      _userProfile = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> createProfile(String username, int dailyGoal) async {
    try {
      final response = await _apiClient.post(
        '/users/create',
        body: {'username': username, 'daily_goal': dailyGoal},
      );

      if (response.statusCode == 201) {
        await checkProfile();
        return true;
      }
    } catch (e) {
      debugPrint('Profile creation error: $e');
    }
    return false;
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        '/auth/password/reset/request',
        body: {'email': email},
      );

      // Backend always returns 200 to prevent user enumeration
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('Password reset request error: $e');
    }
    return false;
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refresh_token');
    _status = AuthStatus.unauthenticated;
    _userProfile = null;
    notifyListeners();
  }
}
