import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bvnController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bvnController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (_validateFirstPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = 1;
        });
      }
    } else {
      _register();
    }
  }

  bool _validateFirstPage() {
    // Manually validate first page fields
    if (_firstNameController.text.isEmpty) {
      _showError('First name is required');
      return false;
    }
    if (_lastNameController.text.isEmpty) {
      _showError('Last name is required');
      return false;
    }
    if (!Validators.isValidEmail(_emailController.text)) {
      _showError('Please enter a valid email address');
      return false;
    }
    if (!Validators.isValidPhoneNumber(_phoneController.text)) {
      _showError('Please enter a valid Nigerian phone number');
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

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        bvn: _bvnController.text.trim(),
      );
      
      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } else if (!_acceptedTerms) {
      _showError('Please accept the terms and conditions to continue');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10.0,
              height: 10.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == 0 ? AppTheme.primaryColor : AppTheme.inactiveColor,
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              width: 10.0,
              height: 10.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == 1 ? AppTheme.primaryColor : AppTheme.inactiveColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              // First Page - Basic Info
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Fill in your details to get started',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    
                    // Form Fields
                    Row(
                      children: [
                        // First Name
                        Expanded(
                          child: CustomTextField(
                            controller: _firstNameController,
                            labelText: 'First Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: Validators.validateName,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // Last Name
                        Expanded(
                          child: CustomTextField(
                            controller: _lastNameController,
                            labelText: 'Last Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: Validators.validateName,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Email
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Phone
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: Validators.validatePhoneNumber,
                      helperText: 'Nigerian mobile number (e.g., 080xxxxxxxx)',
                    ),
                    const SizedBox(height: 40.0),
                    
                    // Next Button
                    CustomButton(
                      text: 'Next',
                      onPressed: _nextPage,
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Login Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Second Page - Security Details
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Security Details',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Set up your security information',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    
                    // Form Fields
                    // BVN
                    CustomTextField(
                      controller: _bvnController,
                      labelText: 'BVN (Bank Verification Number)',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      validator: Validators.validateBVN,
                      helperText: 'Your 11-digit Bank Verification Number',
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: Validators.validatePassword,
                      helperText: 'Min. 8 characters with letters, numbers & symbols',
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Confirm Password
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) => Validators.validateConfirmPassword(
                        value, _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Terms and Conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value!;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                color: AppTheme.secondaryTextColor,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' and ',
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Error Message
                    if (authService.error != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                authService.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32.0),
                    
                    // Register Button
                    CustomButton(
                      text: 'Create Account',
                      onPressed: authService.isLoading ? null : _register,
                      isLoading: authService.isLoading,
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Back Button
                    CustomButton(
                      text: 'Previous',
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          _currentPage = 0;
                        });
                      },
                      color: Colors.transparent,
                      textColor: AppTheme.primaryColor,
                      borderColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
