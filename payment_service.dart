import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/transaction.dart';
import '../models/bill.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class PaymentService extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _error;
  List<Transaction> _recentTransactions = [];
  List<BillProvider> _billProviders = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Transaction> get recentTransactions => _recentTransactions;
  List<BillProvider> get billProviders => _billProviders;

  // Get token from secure storage
  Future<String?> get _getToken async {
    return await storage.read(key: 'auth_token');
  }

  // Get recent transactions
  Future<List<Transaction>> getRecentTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return [];
      }

      // First try to get from local storage for offline support
      final cachedTransactions = await StorageService.getTransactions();
      if (cachedTransactions.isNotEmpty) {
        _recentTransactions = cachedTransactions;
      }
      
      // Then fetch from API
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transactions = (data['transactions'] as List)
            .map((item) => Transaction.fromJson(item))
            .toList();
        
        _recentTransactions = transactions;
        
        // Store in local storage for offline access
        await StorageService.saveTransactions(transactions);
        
        _isLoading = false;
        notifyListeners();
        return transactions;
      } else {
        // If API fails but we have cached data, use that
        if (_recentTransactions.isNotEmpty) {
          _isLoading = false;
          notifyListeners();
          return _recentTransactions;
        }
        
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to load transactions';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      // If exception but we have cached data, use that
      if (_recentTransactions.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return _recentTransactions;
      }
      
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Get transaction details
  Future<Transaction?> getTransactionDetails(String transactionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // First check in local transactions
      final cachedTransaction = _recentTransactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => Transaction(
          id: '',
          reference: '',
          amount: 0,
          type: TransactionType.transfer,
          status: TransactionStatus.pending,
          description: '',
          recipientName: '',
          recipientAccountNumber: '',
          recipientBankName: '',
          senderName: '',
          senderAccountNumber: '',
          senderBankName: '',
          createdAt: DateTime.now(),
        ),
      );
      
      if (cachedTransaction.id.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return cachedTransaction;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/transactions/$transactionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transaction = Transaction.fromJson(data['transaction']);
        
        _isLoading = false;
        notifyListeners();
        return transaction;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to load transaction details';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Transfer money
  Future<Transaction?> transferMoney({
    required String recipientBankCode,
    required String recipientAccountNumber,
    required double amount,
    required String narration,
    String? pin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/transfers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipient_bank_code': recipientBankCode,
          'recipient_account_number': recipientAccountNumber,
          'amount': amount,
          'narration': narration,
          'pin': pin,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final transaction = Transaction.fromJson(data['transaction']);
        
        // Update cached transaction list
        _recentTransactions.insert(0, transaction);
        await StorageService.saveTransactions(_recentTransactions);
        
        _isLoading = false;
        notifyListeners();
        return transaction;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Transfer failed';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Verify account number
  Future<Map<String, dynamic>?> verifyAccountNumber({
    required String bankCode,
    required String accountNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/banks/verify-account?bank_code=$bankCode&account_number=$accountNumber'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        _isLoading = false;
        notifyListeners();
        return data;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Could not verify account number';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get banks list
  Future<List<Map<String, dynamic>>> getBanks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return [];
      }

      // Try to get from cache first
      final cachedBanks = await StorageService.getBanks();
      if (cachedBanks.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return cachedBanks;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/banks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final banks = List<Map<String, dynamic>>.from(data['banks']);
        
        // Cache for offline use
        await StorageService.saveBanks(banks);
        
        _isLoading = false;
        notifyListeners();
        return banks;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to load banks';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Get bill providers
  Future<List<BillProvider>> getBillProviders({BillCategory? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return [];
      }

      // Try to get from cache first
      if (_billProviders.isNotEmpty && category == null) {
        _isLoading = false;
        notifyListeners();
        return _billProviders;
      }

      final cachedProviders = await StorageService.getBillProviders();
      if (cachedProviders.isNotEmpty) {
        _billProviders = cachedProviders;
        
        if (category != null) {
          final filtered = _billProviders.where((p) => p.category == category).toList();
          _isLoading = false;
          notifyListeners();
          return filtered;
        }
      }

      String url = '${AppConfig.baseUrl}/bills/providers';
      if (category != null) {
        final categoryStr = category.toString().split('.').last;
        url += '?category=$categoryStr';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final providers = (data['providers'] as List)
            .map((item) => BillProvider.fromJson(item))
            .toList();
        
        if (category == null) {
          _billProviders = providers;
          // Cache for offline use
          await StorageService.saveBillProviders(providers);
        }
        
        _isLoading = false;
        notifyListeners();
        
        if (category != null) {
          return providers;
        }
        return _billProviders;
      } else {
        // If API call fails but we have cached data
        if (_billProviders.isNotEmpty) {
          if (category != null) {
            final filtered = _billProviders.where((p) => p.category == category).toList();
            _isLoading = false;
            notifyListeners();
            return filtered;
          }
          _isLoading = false;
          notifyListeners();
          return _billProviders;
        }
        
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to load bill providers';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      // If exception but we have cached data
      if (_billProviders.isNotEmpty) {
        if (category != null) {
          final filtered = _billProviders.where((p) => p.category == category).toList();
          _isLoading = false;
          notifyListeners();
          return filtered;
        }
        _isLoading = false;
        notifyListeners();
        return _billProviders;
      }
      
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Validate bill customer
  Future<BillCustomerValidation?> validateBillCustomer({
    required String providerId,
    required String customerId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/bills/validate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider_id': providerId,
          'customer_id': customerId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final validation = BillCustomerValidation.fromJson(data['customer']);
        
        _isLoading = false;
        notifyListeners();
        return validation;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to validate customer';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Pay bill
  Future<BillPayment?> payBill({
    required String providerId,
    required String customerId,
    required double amount,
    required String pin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/bills/pay'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider_id': providerId,
          'customer_id': customerId,
          'amount': amount,
          'pin': pin,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final payment = BillPayment.fromJson(data['payment']);
        
        // Add to recent transactions
        final transaction = Transaction(
          id: payment.id,
          reference: payment.reference,
          amount: payment.amount,
          type: TransactionType.billPayment,
          status: payment.status == 'completed' 
              ? TransactionStatus.completed 
              : TransactionStatus.pending,
          description: 'Bill payment to ${payment.providerName}',
          recipientName: payment.providerName,
          recipientAccountNumber: payment.customerId,
          recipientBankName: '',
          senderName: '',
          senderAccountNumber: '',
          senderBankName: '',
          createdAt: payment.createdAt,
          completedAt: payment.completedAt,
          category: 'bill_payment',
          billReference: payment.reference,
        );
        
        _recentTransactions.insert(0, transaction);
        await StorageService.saveTransactions(_recentTransactions);
        
        _isLoading = false;
        notifyListeners();
        return payment;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Bill payment failed';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Buy airtime
  Future<Transaction?> buyAirtime({
    required String phoneNumber,
    required String provider,
    required double amount,
    required String pin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/airtime'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'provider': provider,
          'amount': amount,
          'pin': pin,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final transaction = Transaction.fromJson(data['transaction']);
        
        // Update cached transaction list
        _recentTransactions.insert(0, transaction);
        await StorageService.saveTransactions(_recentTransactions);
        
        _isLoading = false;
        notifyListeners();
        return transaction;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Airtime purchase failed';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Buy data
  Future<Transaction?> buyData({
    required String phoneNumber,
    required String provider,
    required String dataCode,
    required double amount,
    required String pin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/data'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'provider': provider,
          'data_code': dataCode,
          'amount': amount,
          'pin': pin,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final transaction = Transaction.fromJson(data['transaction']);
        
        // Update cached transaction list
        _recentTransactions.insert(0, transaction);
        await StorageService.saveTransactions(_recentTransactions);
        
        _isLoading = false;
        notifyListeners();
        return transaction;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Data purchase failed';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get data plans
  Future<List<Map<String, dynamic>>> getDataPlans(String provider) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return [];
      }

      // Try to get from cache first
      final cachedPlans = await StorageService.getDataPlans(provider);
      if (cachedPlans.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return cachedPlans;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/data/plans?provider=$provider'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final plans = List<Map<String, dynamic>>.from(data['plans']);
        
        // Cache for offline use
        await StorageService.saveDataPlans(provider, plans);
        
        _isLoading = false;
        notifyListeners();
        return plans;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to load data plans';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Network error. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
