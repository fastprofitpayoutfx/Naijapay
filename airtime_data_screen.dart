import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../config/theme.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AirtimeDataScreen extends StatefulWidget {
  const AirtimeDataScreen({Key? key}) : super(key: key);

  @override
  State<AirtimeDataScreen> createState() => _AirtimeDataScreenState();
}

class _AirtimeDataScreenState extends State<AirtimeDataScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  String? _selectedNetwork;
  String? _selectedDataPlan;
  Map<String, dynamic>? _selectedPlanDetails;
  bool _isLoadingDataPlans = false;
  List<Map<String, dynamic>> _dataPlans = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Reset form when switching tabs
      setState(() {
        _selectedNetwork = null;
        _selectedDataPlan = null;
        _selectedPlanDetails = null;
        _phoneController.clear();
        _amountController.clear();
      });
    }
  }
  
  Future<void> _loadDataPlans() async {
    if (_selectedNetwork == null) return;
    
    setState(() {
      _isLoadingDataPlans = true;
      _selectedDataPlan = null;
      _selectedPlanDetails = null;
    });
    
    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final plans = await paymentService.getDataPlans(_selectedNetwork!);
      
      setState(() {
        _dataPlans = plans;
        _isLoadingDataPlans = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDataPlans = false;
        _dataPlans = [];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data plans: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _selectDataPlan(String planId, Map<String, dynamic> planDetails) {
    setState(() {
      _selectedDataPlan = planId;
      _selectedPlanDetails = planDetails;
      _amountController.text = planDetails['price'].toString();
    });
  }
  
  bool _validateAirtimeForm() {
    if (_selectedNetwork == null) {
      _showError('Please select a network provider');
      return false;
    }
    
    if (_phoneController.text.isEmpty || !Validators.isValidPhoneNumber(_phoneController.text)) {
      _showError('Please enter a valid phone number');
      return false;
    }
    
    if (_amountController.text.isEmpty) {
      _showError('Please enter amount');
      return false;
    }
    
    try {
      final amount = double.parse(_amountController.text);
      if (amount < 50) {
        _showError('Minimum amount is ₦50');
        return false;
      }
      if (amount > 50000) {
        _showError('Maximum amount is ₦50,000');
        return false;
      }
    } catch (e) {
      _showError('Please enter a valid amount');
      return false;
    }
    
    return true;
  }
  
  bool _validateDataForm() {
    if (_selectedNetwork == null) {
      _showError('Please select a network provider');
      return false;
    }
    
    if (_phoneController.text.isEmpty || !Validators.isValidPhoneNumber(_phoneController.text)) {
      _showError('Please enter a valid phone number');
      return false;
    }
    
    if (_selectedDataPlan == null) {
      _showError('Please select a data plan');
      return false;
    }
    
    return true;
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _showAirtimeConfirmation() {
    if (!_validateAirtimeForm()) return;
    
    final amount = double.parse(_amountController.text);
    final phoneNumber = _phoneController.text.trim();
    
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
                  'Confirm Airtime Purchase',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Airtime Details
              const Text(
                'Purchase Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDetailRow('Network:', NetworkProviders.getName(_selectedNetwork!)),
              _buildDetailRow('Phone Number:', phoneNumber),
              _buildDetailRow('Amount:', '₦$amount'),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Fee and Total
              _buildDetailRow(
                'Service Fee:',
                'Free',
                showDivider: false,
              ),
              _buildDetailRow(
                'Total:',
                '₦$amount',
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
                          text: 'Buy Airtime',
                          isLoading: paymentService.isLoading,
                          onPressed: paymentService.isLoading
                              ? null
                              : () => _processAirtimePurchase(paymentService),
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
  
  void _showDataConfirmation() {
    if (!_validateDataForm()) return;
    
    final phoneNumber = _phoneController.text.trim();
    final dataAmount = _selectedPlanDetails!['price'].toString();
    final dataSize = _selectedPlanDetails!['name'];
    
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
                  'Confirm Data Purchase',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Data Details
              const Text(
                'Purchase Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDetailRow('Network:', NetworkProviders.getName(_selectedNetwork!)),
              _buildDetailRow('Phone Number:', phoneNumber),
              _buildDetailRow('Data Plan:', dataSize),
              _buildDetailRow('Validity:', _selectedPlanDetails!['validity'] ?? 'N/A'),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Fee and Total
              _buildDetailRow(
                'Service Fee:',
                'Free',
                showDivider: false,
              ),
              _buildDetailRow(
                'Total:',
                '₦$dataAmount',
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
                          text: 'Buy Data',
                          isLoading: paymentService.isLoading,
                          onPressed: paymentService.isLoading
                              ? null
                              : () => _processDataPurchase(paymentService),
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
  
  Future<void> _processAirtimePurchase(PaymentService paymentService) async {
    if (_pinController.text.length != 4) {
      _showError('Please enter a valid 4-digit PIN');
      return;
    }

    final amount = double.parse(_amountController.text);
    final phoneNumber = _phoneController.text.trim();
    final pin = _pinController.text;

    try {
      final transaction = await paymentService.buyAirtime(
        phoneNumber: phoneNumber,
        provider: _selectedNetwork!,
        amount: amount,
        pin: pin,
      );

      if (transaction != null && mounted) {
        // Close the modal
        Navigator.pop(context);
        
        // Show success dialog
        _showSuccessDialog(
          'Airtime Purchase Successful',
          'You have successfully purchased ₦$amount airtime for $phoneNumber',
        );
      }
    } catch (e) {
      // Close the modal
      Navigator.pop(context);
      
      _showError('Purchase failed: ${paymentService.error ?? e.toString()}');
    }
  }
  
  Future<void> _processDataPurchase(PaymentService paymentService) async {
    if (_pinController.text.length != 4) {
      _showError('Please enter a valid 4-digit PIN');
      return;
    }

    final phoneNumber = _phoneController.text.trim();
    final amount = double.parse(_selectedPlanDetails!['price'].toString());
    final pin = _pinController.text;

    try {
      final transaction = await paymentService.buyData(
        phoneNumber: phoneNumber,
        provider: _selectedNetwork!,
        dataCode: _selectedDataPlan!,
        amount: amount,
        pin: pin,
      );

      if (transaction != null && mounted) {
        // Close the modal
        Navigator.pop(context);
        
        // Show success dialog
        _showSuccessDialog(
          'Data Purchase Successful',
          'You have successfully purchased ${_selectedPlanDetails!['name']} data for $phoneNumber',
        );
      }
    } catch (e) {
      // Close the modal
      Navigator.pop(context);
      
      _showError('Purchase failed: ${paymentService.error ?? e.toString()}');
    }
  }
  
  void _showSuccessDialog(String title, String message) {
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
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
                  
                  // Reset form
                  setState(() {
                    _selectedNetwork = null;
                    _selectedDataPlan = null;
                    _selectedPlanDetails = null;
                    _phoneController.clear();
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
        title: const Text('Airtime & Data'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Airtime'),
            Tab(text: 'Data'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAirtimeTab(),
          _buildDataTab(),
        ],
      ),
    );
  }
  
  Widget _buildAirtimeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buy Airtime',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select network and enter details',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Network Selection
          const Text(
            'Select Network',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildNetworkSelection(),
          const SizedBox(height: 24),
          
          // Phone Number
          const Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _phoneController,
            hintText: 'Enter phone number',
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhoneNumber,
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
            hintText: 'Enter amount',
            prefixText: '₦ ',
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 8),
          
          // Quick amounts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [100, 200, 500, 1000, 2000, 5000].map((amount) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _amountController.text = amount.toString();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '₦$amount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Buy Button
          CustomButton(
            text: 'Buy Airtime',
            onPressed: _showAirtimeConfirmation,
          ),
          
          const SizedBox(height: 16),
          
          // Save Beneficiary option
          Row(
            children: [
              Checkbox(
                value: false, // Could be controlled with a state variable
                onChanged: (value) {
                  // Save logic here
                },
                activeColor: AppTheme.primaryColor,
              ),
              const Text(
                'Save as Beneficiary',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buy Data Bundle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select network and data plan',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Network Selection
          const Text(
            'Select Network',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildNetworkSelection(),
          const SizedBox(height: 24),
          
          // Phone Number
          const Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _phoneController,
            hintText: 'Enter phone number',
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhoneNumber,
          ),
          const SizedBox(height: 24),
          
          // Data Plans
          if (_selectedNetwork != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Data Plan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                if (_isLoadingDataPlans)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            _isLoadingDataPlans
                ? _buildDataPlansLoadingShimmer()
                : _dataPlans.isEmpty
                    ? _buildEmptyDataPlans()
                    : _buildDataPlansList(),
            
            const SizedBox(height: 40),
            
            // Buy Button
            if (_selectedDataPlan != null)
              CustomButton(
                text: 'Buy Data',
                onPressed: _showDataConfirmation,
              ),
            
            const SizedBox(height: 16),
            
            // Save Beneficiary option
            if (_selectedDataPlan != null)
              Row(
                children: [
                  Checkbox(
                    value: false, // Could be controlled with a state variable
                    onChanged: (value) {
                      // Save logic here
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Text(
                    'Save as Beneficiary',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildNetworkSelection() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: NetworkProviders.providers.map((provider) {
        final isSelected = _selectedNetwork == provider.code;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedNetwork = provider.code;
              _selectedDataPlan = null;
              _selectedPlanDetails = null;
            });
            
            if (_tabController.index == 1) {
              _loadDataPlans();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  provider.icon,
                  color: provider.color,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  provider.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildDataPlansLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            height: 80,
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyDataPlans() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No data plans available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try another network provider',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataPlansList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dataPlans.length,
      itemBuilder: (context, index) {
        final plan = _dataPlans[index];
        final isSelected = _selectedDataPlan == plan['code'];
        
        return GestureDetector(
          onTap: () {
            _selectDataPlan(plan['code'], plan);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Validity: ${plan['validity'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? AppTheme.primaryColor.withOpacity(0.8) : AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₦${plan['price']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
