class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Email pattern check
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    
    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name is too short';
    }
    
    return null;
  }
  
  // Nigerian phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    if (!isValidPhoneNumber(value)) {
      return 'Please enter a valid Nigerian phone number';
    }
    
    return null;
  }
  
  // Phone number pattern check for Nigeria
  static bool isValidPhoneNumber(String phone) {
    // Nigeria phone numbers patterns:
    // +234xxxxxxxxxx
    // 234xxxxxxxxxx
    // 0xxxxxxxxxx
    final phoneRegex = RegExp(
      r'^([0]|[+]?234)([7-9][01]\d{8})$',
    );
    return phoneRegex.hasMatch(phone);
  }
  
  // BVN validation
  static String? validateBVN(String? value) {
    if (value == null || value.isEmpty) {
      return 'BVN is required';
    }
    
    // BVN is 11 digits
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'BVN must be 11 digits';
    }
    
    return null;
  }
  
  // PIN validation
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    
    // PIN is 4 digits
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'PIN must be 4 digits';
    }
    
    return null;
  }
  
  // Account number validation
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }
    
    // Nigerian bank account numbers are 10 digits
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Account number must be 10 digits';
    }
    
    return null;
  }
  
  // Amount validation
  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    double? amount;
    try {
      amount = double.parse(value);
    } catch (e) {
      return 'Please enter a valid amount';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    
    if (min != null && amount < min) {
      return 'Minimum amount is ₦${min.toStringAsFixed(2)}';
    }
    
    if (max != null && amount > max) {
      return 'Maximum amount is ₦${max.toStringAsFixed(2)}';
    }
    
    return null;
  }
}
