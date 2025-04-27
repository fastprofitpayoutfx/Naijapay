import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';

class ApiService {
  static const storage = FlutterSecureStorage();
  
  // HTTP Client with timeouts
  static final _client = http.Client();

  // Get token from secure storage
  static Future<String?> get _getToken async {
    return await storage.read(key: 'auth_token');
  }

  // Handle API responses
  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = json.decode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      final message = responseBody['message'] ?? 'An error occurred';
      throw ApiException(
        statusCode: statusCode,
        message: message,
        details: responseBody['details'],
      );
    }
  }

  // GET request
  static Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final token = await _getToken;
      
      Uri uri = Uri.parse('${AppConfig.baseUrl}/$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(milliseconds: AppConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } on HttpException {
      throw const ApiException(
        statusCode: 0,
        message: 'Service not available',
      );
    } on FormatException {
      throw const ApiException(
        statusCode: 0,
        message: 'Invalid response format',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 0,
        message: e.toString(),
      );
    }
  }

  // POST request
  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final token = await _getToken;
      
      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(milliseconds: AppConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } on HttpException {
      throw const ApiException(
        statusCode: 0,
        message: 'Service not available',
      );
    } on FormatException {
      throw const ApiException(
        statusCode: 0,
        message: 'Invalid response format',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 0,
        message: e.toString(),
      );
    }
  }

  // PUT request
  static Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final token = await _getToken;
      
      final response = await _client.put(
        Uri.parse('${AppConfig.baseUrl}/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(milliseconds: AppConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } on HttpException {
      throw const ApiException(
        statusCode: 0,
        message: 'Service not available',
      );
    } on FormatException {
      throw const ApiException(
        statusCode: 0,
        message: 'Invalid response format',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 0,
        message: e.toString(),
      );
    }
  }

  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final token = await _getToken;
      
      final response = await _client.delete(
        Uri.parse('${AppConfig.baseUrl}/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(milliseconds: AppConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } on HttpException {
      throw const ApiException(
        statusCode: 0,
        message: 'Service not available',
      );
    } on FormatException {
      throw const ApiException(
        statusCode: 0,
        message: 'Invalid response format',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 0,
        message: e.toString(),
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: [$statusCode] $message';
  }
}
