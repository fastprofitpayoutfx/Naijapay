import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../config/theme.dart';
import '../models/bill.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';
import '../widgets/bill_category_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

class BillPaymentScreen extends StatefulWidget {
  const BillPaymentScreen({Key? key}) : super(key: key);

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  BillCategory? _selectedCategory;
  BillProvider? _selectedProvider;
  BillCustomerValidation? _customerValidation;
  
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  bool _isValidatingCustomer = false;
  bool _isCustomerValidated = false;
  List<BillProvider> _providers = [];
  bool _isLoadingProviders = false;
  
  @override
  void dispose() {
    _customerIdController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _selectCategory(BillCategory category) {
    setState(() {
      _selectedCategory = category;
      _selectedProvider = null;
      _customerValidation = null;
      _isCustomerValidated = false;
      _providers = [];
    });
    _loadProviders(category);
  }

  Future<void> _loadProviders(BillCategory category) async {
    setState(() {
      _isLoadingProviders = true;
    });
    
    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final providers = await paymentService.getBillProviders(category: category);
      
      setState(() {
        _providers = providers;
        _isLoadingProviders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProviders = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load providers: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectProvider(BillProvider provider) {
    setState(() {
      _selectedProvider = provider;
      _customerValidation = null;
      _isCustomerValidated = false;
      _customerIdController.clear();
      _amountController.clear();
    });
  }

  Future<void> _validateCustomer() async {
    if (_selectedProvider == null || _customerIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a provider and enter customer ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isValidatingCustomer = true;
      _customerValidation = null;
      _isCustomerValidated = false;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final validation = await paymentService.validateBillCustomer(
        providerId: _selectedProvider!.id,
        customerId: _customerIdController.text.trim(),
      );
      
      if (validation != null) {
        setState(() {
          _customerValidation = validation;
          _isCustomerValidated = true;
          
          // If provider has a minimum/maximum amount, pre-fill amount
          if (validation.minimumAmount != null) {
            _amountController.text = validation.minimumAmount!;
          } else if (validation.balance != null) {
            _amountController.text = validation.balance!;
          }
        });
      } else {
        setState(() {
          _customerValidation = null;
          _isCustomerValidated = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Customer validation failed: ${paymentService.error ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isValidatingCustomer = false;
      });
    }
  }

  void _showPaymentConfirmation() {
    if (_selectedProvider == null || !_isCustomerValidated || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields and validate customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
                  'Confirm Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Payment Details
              const Text(
                'Bill Payment Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDetailRow('Provider:', _selectedProvider!.name),
              _buildDetailRow('Customer ID:', _customerIdController.text),
              _buildDetailRow('Customer Name:', _customerValidation!.customerName),
              if (_customerValidation!.customerAddress.isNotEmpty)
                _buildDetailRow('Address:', _customerValidation!.customerAddress),
              _buildDetailRow('Amount:', '₦${_amountController.text}'),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Fee and Total
              _buildDetailRow(
                'Service Fee:',
                '₦25.00',
                showDivider: false,
              ),
              _buildDetailRow(
                'Total:',
                '₦${(amount + 25).toStringAsFixed(2)}',
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
                          text: 'Pay Bill',
                          isLoading: paymentService.isLoading,
                          onPressed: paymentService.isLoading
                              ? null
                              : () => _processBillPayment(paymentService),
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

  Future<void> _processBillPayment(PaymentService paymentService) async {
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
    final providerId = _selectedProvider!.id;
    final customerId = _customerIdController.text.trim();
    final pin = _pinController.text;

    try {
      final payment = await paymentService.payBill(
        providerId: providerId,
        customerId: customerId,
        amount: amount,
        pin: pin,
      );

      if (payment != null && mounted) {
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
                    'Payment Successful',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have successfully paid ₦$amount to ${_selectedProvider!.name} for ${_customerValidation!.customerName}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  if (payment.receiptNumber != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Receipt Number: ${payment.receiptNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      
                      // Reset form
                      setState(() {
                        _selectedProvider = null;
                        _customerValidation = null;
                        _isCustomerValidated = false;
                        _customerIdController.clear();
                        _amountController.clear();
                      });
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
          content: Text('Payment failed: ${paymentService.error ?? e.toString()}'),
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
        title: const Text('Bill Payments'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _selectedCategory == null
            ? _buildCategoriesGrid()
            : _selectedProvider == null
                ? _buildProvidersList()
                : _buildPaymentForm(),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Bill Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'What bill would you like to pay?',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: BillCategories.categories.map((category) {
              return BillCategoryCard(
                title: category.name,
                icon: category.icon,
                color: category.color,
                onTap: () => _selectCategory(category.category),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersList() {
    return Column(
      children: [
        // Header with back button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BillCategories.getCategoryName(_selectedCategory!),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select your service provider',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Providers list
        Expanded(
          child: _isLoadingProviders
              ? _buildLoadingShimmer()
              : _providers.isEmpty
                  ? _buildEmptyProviders()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _providers.length,
                      itemBuilder: (context, index) {
                        final provider = _providers[index];
                        return _buildProviderItem(provider);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyProviders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No providers available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try another category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
              });
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderItem(BillProvider provider) {
    return GestureDetector(
      onTap: () => _selectProvider(provider),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Provider logo
            if (provider.logoUrl.isNotEmpty)
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(provider.logoUrl),
              )
            else
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                child: Text(
                  provider.name.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            const SizedBox(width: 16),
            
            // Provider details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  if (provider.description != null && provider.description!.isNotEmpty)
                    Text(
                      provider.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                ],
              ),
            ),
            
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with provider details
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedProvider = null;
                    _customerValidation = null;
                    _isCustomerValidated = false;
                    _customerIdController.clear();
                    _amountController.clear();
                  });
                },
              ),
              const SizedBox(width: 8),
              if (_selectedProvider != null) ...[
                // Provider logo
                if (_selectedProvider!.logoUrl.isNotEmpty)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage(_selectedProvider!.logoUrl),
                  )
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      _selectedProvider!.name.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                
                // Provider name
                Expanded(
                  child: Text(
                    _selectedProvider!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          
          // Form
          const Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Customer ID
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _customerIdController,
                  labelText: 'Customer ID / Meter Number',
                  hintText: 'Enter your customer ID',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your customer ID';
                    }
                    return null;
                  },
                  enabled: !_isCustomerValidated,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValidatingCustomer || _isCustomerValidated ? null : _validateCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isValidatingCustomer
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_isCustomerValidated ? 'Verified' : 'Verify'),
                ),
              ),
            ],
          ),
          
          // Customer validation result
          if (_customerValidation != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCustomerValidated
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isCustomerValidated ? Icons.check_circle : Icons.error,
                        color: _isCustomerValidated ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _customerValidation!.customerName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isCustomerValidated ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_customerValidation!.customerAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _customerValidation!.customerAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: _isCustomerValidated ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                  if (_customerValidation!.balance != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Current Balance: ₦${_customerValidation!.balance}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isCustomerValidated ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                  if (_customerValidation!.dueDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Due Date: ${_customerValidation!.dueDate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isCustomerValidated ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Amount
          if (_isCustomerValidated) ...[
            const Text(
              'Payment Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              labelText: 'Amount',
              hintText: 'Enter amount',
              prefixText: '₦ ',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                try {
                  final amount = double.parse(value);
                  if (amount <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  if (_customerValidation?.minimumAmount != null) {
                    final minAmount = double.parse(_customerValidation!.minimumAmount!);
                    if (amount < minAmount) {
                      return 'Minimum amount is ₦${_customerValidation!.minimumAmount}';
                    }
                  }
                  if (_customerValidation?.maximumAmount != null) {
                    final maxAmount = double.parse(_customerValidation!.maximumAmount!);
                    if (amount > maxAmount) {
                      return 'Maximum amount is ₦${_customerValidation!.maximumAmount}';
                    }
                  }
                } catch (e) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 40),
            
            // Pay Button
            CustomButton(
              text: 'Proceed to Payment',
              onPressed: _showPaymentConfirmation,
            ),
          ],
        ],
      ),
    );
  }
}
