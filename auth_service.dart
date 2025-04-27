import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final storage = const FlutterSecureStorage();

  // Initialize auth state from stored data
  Future<bool> initAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final userData = await StorageService.getUser();
      if (userData == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _token = token;
      _currentUser = userData;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to initialize authentication';
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String bvn,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
          'bvn': bvn,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;
        
        // Store authentication data
        await storage.write(key: 'auth_token', value: _token);
        await StorageService.saveUser(_currentUser!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;
        
        // Store authentication data
        await storage.write(key: 'auth_token', value: _token);
        await StorageService.saveUser(_currentUser!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login with phone number and PIN
  Future<bool> loginWithPhone({
    required String phoneNumber,
    required String pin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/login-phone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'pin': pin,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;
        
        // Store authentication data
        await storage.write(key: 'auth_token', value: _token);
        await StorageService.saveUser(_currentUser!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Invalid phone number or PIN';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get user profile
  Future<bool> getUserProfile() async {
    if (_token == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data['user']);
        
        // Update stored user data
        await StorageService.saveUser(_currentUser!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to load user profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) async {
    if (_token == null || _currentUser == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'first_name': firstName ?? _currentUser!.firstName,
          'last_name': lastName ?? _currentUser!.lastName,
          'email': email ?? _currentUser!.email,
          'phone_number': phoneNumber ?? _currentUser!.phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data['user']);
        
        // Update stored user data
        await StorageService.saveUser(_currentUser!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change PIN or password
  Future<bool> changeCredentials({
    String? currentPin,
    String? newPin,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (_token == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final endpoint = currentPin != null ? '/user/change-pin' : '/user/change-password';
      
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(currentPin != null ? {
          'current_pin': currentPin,
          'new_pin': newPin,
        } : {
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to change credentials';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;
    _token = null;
    
    // Clear stored authentication data
    await storage.delete(key: 'auth_token');
    await StorageService.clearUser();
    
    notifyListeners();
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to reset password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP for password reset
  Future<bool> verifyResetOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/verify-reset-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to verify OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
