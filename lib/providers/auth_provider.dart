import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _username = '';
  String _email = '';
  
  bool get isAuthenticated => _isAuthenticated;
  String get username => _username;
  String get email => _email;

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username') ?? '';
    _email = prefs.getString('email') ?? '';
    notifyListeners();
  }

  // Register new user
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    // Validation
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'All fields are required'};
    }
    
    if (!email.contains('@')) {
      return {'success': false, 'message': 'Invalid email format'};
    }
    
    if (password.length < 6) {
      return {'success': false, 'message': 'Password must be at least 6 characters'};
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if email already exists
      final existingEmail = prefs.getString('registered_email');
      if (existingEmail == email) {
        return {'success': false, 'message': 'Email already registered'};
      }
      
      // Save user credentials
      await prefs.setString('registered_username', username);
      await prefs.setString('registered_email', email);
      await prefs.setString('registered_password', password);
      
      return {'success': true, 'message': 'Registration successful'};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Validation
    if (email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Email and password are required'};
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get stored credentials
      final storedEmail = prefs.getString('registered_email');
      final storedPassword = prefs.getString('registered_password');
      final storedUsername = prefs.getString('registered_username');
      
      // Verify credentials
      if (storedEmail == email && storedPassword == password) {
        _isAuthenticated = true;
        _email = email;
        _username = storedUsername ?? '';
        
        // Save login state
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', _username);
        await prefs.setString('email', _email);
        
        notifyListeners();
        return {'success': true, 'message': 'Login successful'};
      } else {
        return {'success': false, 'message': 'Invalid email or password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    
    _isAuthenticated = false;
    _username = '';
    _email = '';
    
    notifyListeners();
  }

  // Update email
  Future<bool> updateEmail(String newEmail) async {
    if (!newEmail.contains('@')) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_email', newEmail);
    await prefs.setString('email', newEmail);
    _email = newEmail;
    notifyListeners();
    return true;
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    if (newPassword.length < 6) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_password', newPassword);
    notifyListeners();
    return true;
  }
}