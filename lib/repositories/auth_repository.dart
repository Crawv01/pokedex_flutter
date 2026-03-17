import 'package:shared_preferences/shared_preferences.dart';

/// AuthRepository handles authentication data operations
class AuthRepository {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';

  /// Attempts to log in with the given credentials
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo purposes, accept any non-empty credentials
    if (username.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUsername, username);
      return true;
    }
    return false;
  }

  /// Logs out the current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUsername);
  }

  /// Checks if the user is currently authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Gets the current user's username
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }
}
