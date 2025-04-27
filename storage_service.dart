import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user.dart';
import '../models/transaction.dart';
import '../models/bill.dart';

class StorageService {
  static late Box _box;
  
  // Storage Keys
  static const String userKey = 'user_data';
  static const String transactionsKey = 'transactions';
  static const String banksKey = 'banks';
  static const String billProvidersKey = 'bill_providers';
  static const String dataPlansPrefix = 'data_plans_';
  
  // Initialize Hive and open box
  static Future<void> init() async {
    _box = await Hive.openBox('naijapay_storage');
  }
  
  // User data
  static Future<void> saveUser(User user) async {
    await _box.put(userKey, jsonEncode(user.toJson()));
  }
  
  static Future<User?> getUser() async {
    final userData = _box.get(userKey);
    if (userData == null) return null;
    
    return User.fromJson(jsonDecode(userData));
  }
  
  static Future<void> clearUser() async {
    await _box.delete(userKey);
  }
  
  // Transactions
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final transactionsJson = transactions.map((t) => t.toJson()).toList();
    await _box.put(transactionsKey, jsonEncode(transactionsJson));
  }
  
  static Future<List<Transaction>> getTransactions() async {
    final transactionsData = _box.get(transactionsKey);
    if (transactionsData == null) return [];
    
    final List<dynamic> transactionsJson = jsonDecode(transactionsData);
    return transactionsJson.map((t) => Transaction.fromJson(t)).toList();
  }
  
  static Future<void> clearTransactions() async {
    await _box.delete(transactionsKey);
  }
  
  // Banks
  static Future<void> saveBanks(List<Map<String, dynamic>> banks) async {
    await _box.put(banksKey, jsonEncode(banks));
  }
  
  static Future<List<Map<String, dynamic>>> getBanks() async {
    final banksData = _box.get(banksKey);
    if (banksData == null) return [];
    
    final List<dynamic> banksJson = jsonDecode(banksData);
    return banksJson.map((b) => Map<String, dynamic>.from(b)).toList();
  }
  
  // Bill Providers
  static Future<void> saveBillProviders(List<BillProvider> providers) async {
    final providersJson = providers.map((p) => p.toJson()).toList();
    await _box.put(billProvidersKey, jsonEncode(providersJson));
  }
  
  static Future<List<BillProvider>> getBillProviders() async {
    final providersData = _box.get(billProvidersKey);
    if (providersData == null) return [];
    
    final List<dynamic> providersJson = jsonDecode(providersData);
    return providersJson.map((p) => BillProvider.fromJson(p)).toList();
  }
  
  // Data Plans
  static Future<void> saveDataPlans(String provider, List<Map<String, dynamic>> plans) async {
    await _box.put('$dataPlansPrefix$provider', jsonEncode(plans));
  }
  
  static Future<List<Map<String, dynamic>>> getDataPlans(String provider) async {
    final plansData = _box.get('$dataPlansPrefix$provider');
    if (plansData == null) return [];
    
    final List<dynamic> plansJson = jsonDecode(plansData);
    return plansJson.map((p) => Map<String, dynamic>.from(p)).toList();
  }
  
  // Clear all data
  static Future<void> clearAll() async {
    await _box.clear();
  }
  
  // Check if data exists (useful for offline detection)
  static bool hasData(String key) {
    return _box.containsKey(key);
  }
  
  // Set general data
  static Future<void> setValue(String key, dynamic value) async {
    if (value is Map || value is List) {
      await _box.put(key, jsonEncode(value));
    } else {
      await _box.put(key, value);
    }
  }
  
  // Get general data
  static dynamic getValue(String key) {
    final value = _box.get(key);
    if (value == null) return null;
    
    if (value is String) {
      try {
        return jsonDecode(value);
      } catch (_) {
        return value;
      }
    }
    
    return value;
  }
}
