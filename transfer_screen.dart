import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/theme.dart';
import '../services/payment_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  String? _selectedBankCode;
  String? _accountName;
  bool _isVerifying = false;
  bool _isNameVerified = false;
  bool _isSameBank = false;
  List<Map<String, dynamic>> _banksList = [];
  bool _isLoadingBanks = true;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    _narrationController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    try {
      final banks = await paymentService.getBanks();
      setState(() {
        _banksList = banks;
        _isLoadingBanks = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBanks = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load banks: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyAccountNumber() async {
    if (_selectedBankCode == null || _accountNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bank and enter account number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _isNameVerified = false;
      _accountName = null;
    });

    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    try {
      final response = await paymentService.verifyAccountNumber(
        bankCode: _selectedBankCode!,
        accountNumber: _accountNumberController.text.trim(),
      );
      
      if (response != null && response['account_name'] != null) {
        setState(() {
          _accountName = response['account_name'];
          _isNameVerified = true;
          // Check if it's a transfer to the same bank (NaijaPay to NaijaPay)
          _isSameBank = response['is_same_bank'] ?? false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to verify account number'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _showTransferConfirmation() {
    if (!_formKey.currentState!.validate() || !_isNameVerified) {
      // Show error if account name not verified
      if (!_isNameVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify the account number first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Get the bank name
    final bankName = _banksList
        .firstWhere((bank) => bank['code'] == _selectedBankCode, 
            orElse: () => {'name': 'Unknown Bank'})['name'];
    
    final amount = double.parse(_amountController.text);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Confirm Transfer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Transfer Details
              const Text(
                'Transfer Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDetailRow('Bank:', bankName),
              _buildDetailRow('Account Number:', _accountNumberController.text),
              _buildDetailRow('Account Name:', _accountName!),
              _buildDetailRow('Amount:', '₦${_amountController.text}'),
              if (_narrationController.text.isNotEmpty)
                _buildDetailRow('Narration:', _narrationController.text),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Transfer Fee
              _buildDetailRow(
                'Transfer Fee:',
                _isSameBank ? 'Free' : '₦25.00',
                showDivider: false,
              ),
              _buildDetailRow(
                'Total:',
                '₦${(amount + (_isSameBank ? 0 : 25)).toStringAsFixed(2)}',
                isBold: true,
                showDivider: false,
              ),
              
              const SizedBox(height: 24),
              
              // PIN Input
              const Text(
                'Enter your 4-digit PIN to confirm',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _pinController,
                labelText: 'PIN',
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: Validators.validatePin,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey[100],
                      textColor: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<PaymentService>(
                      builder: (context, paymentService, _) {
                        return CustomButton(
                          text: 'Transfer',
                          isLoading: paymentService.isLoading,
                          onPressed: paymentService.isLoading
                              ? null
                              : () => _processTransfer(paymentService),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processTransfer(PaymentService paymentService) async {
    if (_pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 4-digit PIN'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final bankCode = _selectedBankCode!;
    final accountNumber = _accountNumberController.text.trim();
    final narration = _narrationController.text.trim();
    final pin = _pinController.text;

    try {
      final transaction = await paymentService.transferMoney(
        recipientBankCode: bankCode,
        recipientAccountNumber: accountNumber,
        amount: amount,
        narration: narration.isNotEmpty ? narration : 'Transfer from NaijaPay',
        pin: pin,
      );

      if (transaction != null && mounted) {
        // Close the modal
        Navigator.pop(context);
        
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Transfer Successful',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have successfully transferred ₦$amount to $_accountName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to previous screen
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      // Close the modal
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer failed: ${paymentService.error ?? e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool showDivider = true}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: AppTheme.primaryTextColor,
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Bank Selection
              const Text(
                'Select Bank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingBanks)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedBankCode,
                  decoration: InputDecoration(
                    hintText: 'Select a bank',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _banksList.map((bank) {
                    return DropdownMenuItem<String>(
                      value: bank['code'],
                      child: Text(bank['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBankCode = value;
                      _isNameVerified = false;
                      _accountName = null;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a bank';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 16),
              
              // Account Number
              const Text(
                'Account Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      hintText: 'Enter 10-digit account number',
                      validator: Validators.validateAccountNumber,
                      onChanged: (value) {
                        if (value.length == 10) {
                          // Auto verify when 10 digits entered
                          _verifyAccountNumber();
                        } else {
                          setState(() {
                            _isNameVerified = false;
                            _accountName = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyAccountNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Verify'),
                    ),
                  ),
                ],
              ),
              
              // Account Name (shows up after verification)
              if (_accountName != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isNameVerified
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isNameVerified ? Icons.check_circle : Icons.error,
                        color: _isNameVerified ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _accountName!,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _isNameVerified ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
              
              // Amount
              const Text(
                'Amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _amountController,
                prefixText: '₦ ',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hintText: '0.00',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  try {
                    final amount = double.parse(value);
                    if (amount < AppConfig.minTransferAmount) {
                      return 'Minimum amount is ₦${AppConfig.minTransferAmount}';
                    }
                    if (amount > AppConfig.maxTransferAmount) {
                      return 'Maximum amount is ₦${AppConfig.maxTransferAmount}';
                    }
                  } catch (e) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Narration (Optional)
              const Text(
                'Narration (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _narrationController,
                hintText: 'What is this transfer for?',
                maxLength: 100,
              ),
              
              const SizedBox(height: 32),
              
              // Transfer Button
              CustomButton(
                text: 'Continue',
                onPressed: _showTransferConfirmation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
