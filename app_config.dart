import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // API endpoints
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.naijapay.com/v1';
  
  // Payment gateway keys
  static final String paystackPublicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
  static final String flutterwavePublicKey = dotenv.env['FLUTTERWAVE_PUBLIC_KEY'] ?? '';
  
  // App constants
  static const String appName = 'NaijaPay';
  static const String appVersion = '1.0.0';
  
  // Feature flags
  static const bool enableBiometrics = true;
  static const bool enableOfflineMode = true;
  
  // Timeout durations
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds
  
  // Cache expiry
  static const int cacheExpiryDuration = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
  
  // Maximum transaction amounts
  static const double maxTransferAmount = 1000000.0; // 1 million Naira
  static const double minTransferAmount = 100.0; // 100 Naira
}
