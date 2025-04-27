import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailLogin = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _toggleLoginMethod() {
    setState(() {
      _isEmailLogin = !_isEmailLogin;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      bool success;
      if (_isEmailLogin) {
        success = await authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        success = await authService.loginWithPhone(
          phoneNumber: _phoneController.text.trim(),
          pin: _pinController.text,
        );
      }
      
      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Login to your NaijaPay account',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 40.0),
                
                // Login Form
                if (_isEmailLogin) ...[
                  // Email
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.validateEmail,
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
                  ),
                ] else ...[
                  // Phone Number
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    validator: Validators.validatePhoneNumber,
                  ),
                  const SizedBox(height: 24.0),
                  
                  // PIN
                  CustomTextField(
                    controller: _pinController,
                    labelText: '4-Digit PIN',
                    keyboardType: TextInputType.number,
                    obscureText: _obscurePin,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePin = !_obscurePin;
                        });
                      },
                    ),
                    validator: Validators.validatePin,
                    maxLength: 4,
                  ),
                ],
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to password reset screen
                    },
                    child: const Text('Forgot Password?'),
                  ),
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
                const SizedBox(height: 24.0),
                
                // Login Button
                CustomButton(
                  text: 'Login',
                  onPressed: authService.isLoading ? null : _login,
                  isLoading: authService.isLoading,
                ),
                const SizedBox(height: 16.0),
                
                // Toggle Login Method
                TextButton(
                  onPressed: _toggleLoginMethod,
                  child: Text(
                    _isEmailLogin
                        ? 'Login with Phone Number'
                        : 'Login with Email Address',
                    style: const TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 40.0),
                
                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
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
        ),
      ),
    );
  }
}
