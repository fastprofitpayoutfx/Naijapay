import 'package:intl/intl.dart';

// Format currency with comma separators
String formatCurrency(double amount) {
  final formatter = NumberFormat('#,##0.00', 'en_NG');
  return formatter.format(amount);
}

// Format date to readable format
String formatDate(DateTime date) {
  final formatter = DateFormat('MMM d, yyyy');
  return formatter.format(date);
}

// Format datetime to readable format
String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('MMM d, yyyy HH:mm');
  return formatter.format(dateTime);
}

// Format date to day format (Today, Yesterday, or date)
String formatDateToDayFormat(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final dateToCheck = DateTime(date.year, date.month, date.day);

  if (dateToCheck == today) {
    return 'Today';
  } else if (dateToCheck == yesterday) {
    return 'Yesterday';
  } else {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(date);
  }
}

// Format phone number for display
String formatPhoneNumber(String phoneNumber) {
  // Remove any non-digit characters
  String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
  
  // Format for Nigerian numbers
  if (digitsOnly.startsWith('234') && digitsOnly.length == 13) {
    return '+${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 9)} ${digitsOnly.substring(9)}';
  } else if (digitsOnly.startsWith('0') && digitsOnly.length == 11) {
    return '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7)}';
  }
  
  // Return unformatted if it doesn't match expected patterns
  return phoneNumber;
}

// Hide parts of sensitive information
String hidePartially(String text, {int visibleCharsStart = 2, int visibleCharsEnd = 2}) {
  if (text.length <= visibleCharsStart + visibleCharsEnd) {
    return text; // Return the original if it's too short
  }
  
  final start = text.substring(0, visibleCharsStart);
  final end = text.substring(text.length - visibleCharsEnd);
  final hiddenLength = text.length - visibleCharsStart - visibleCharsEnd;
  final hidden = '*' * hiddenLength;
  
  return '$start$hidden$end';
}

// Generate abbreviated name from full name
String getInitials(String fullName) {
  List<String> names = fullName.split(' ');
  String initials = '';
  
  for (var name in names) {
    if (name.isNotEmpty) {
      initials += name[0];
    }
  }
  
  return initials.toUpperCase();
}

// Calculate time ago (e.g. "2 minutes ago")
String getTimeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  
  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return formatDate(dateTime);
  }
}

// Convert bank account number with asterisks for privacy
String maskAccountNumber(String accountNumber) {
  if (accountNumber.length < 6) return accountNumber;
  
  final firstTwo = accountNumber.substring(0, 2);
  final lastFour = accountNumber.substring(accountNumber.length - 4);
  final masked = '*' * (accountNumber.length - 6);
  
  return '$firstTwo$masked$lastFour';
}
