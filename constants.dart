import 'package:flutter/material.dart';
import '../models/bill.dart';

// Network Providers for Airtime & Data
class NetworkProvider {
  final String name;
  final String code;
  final IconData icon;
  final Color color;

  const NetworkProvider({
    required this.name,
    required this.code,
    required this.icon,
    required this.color,
  });
}

class NetworkProviders {
  static const List<NetworkProvider> providers = [
    NetworkProvider(
      name: 'MTN',
      code: 'mtn',
      icon: Icons.network_cell,
      color: Color(0xFFFFCC00),
    ),
    NetworkProvider(
      name: 'Airtel',
      code: 'airtel',
      icon: Icons.network_cell,
      color: Color(0xFFFF0000),
    ),
    NetworkProvider(
      name: 'Glo',
      code: 'glo',
      icon: Icons.network_cell,
      color: Color(0xFF00A54F),
    ),
    NetworkProvider(
      name: '9mobile',
      code: '9mobile',
      icon: Icons.network_cell,
      color: Color(0xFF006633),
    ),
  ];

  static String getName(String code) {
    final provider = providers.firstWhere(
      (p) => p.code == code,
      orElse: () => const NetworkProvider(
        name: 'Unknown',
        code: 'unknown',
        icon: Icons.network_cell,
        color: Colors.grey,
      ),
    );
    return provider.name;
  }
}

// Bill Categories
class BillCategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  final BillCategory category;

  const BillCategoryInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class BillCategories {
  static const List<BillCategoryInfo> categories = [
    BillCategoryInfo(
      name: 'Electricity',
      icon: Icons.electric_bolt,
      color: Color(0xFFFFCC00),
      category: BillCategory.electricity,
    ),
    BillCategoryInfo(
      name: 'Water',
      icon: Icons.water_drop,
      color: Color(0xFF00A1E4),
      category: BillCategory.water,
    ),
    BillCategoryInfo(
      name: 'Internet',
      icon: Icons.wifi,
      color: Color(0xFF00C853),
      category: BillCategory.internet,
    ),
    BillCategoryInfo(
      name: 'TV',
      icon: Icons.tv,
      color: Color(0xFFFF5722),
      category: BillCategory.tv,
    ),
    BillCategoryInfo(
      name: 'Education',
      icon: Icons.school,
      color: Color(0xFF6200EA),
      category: BillCategory.education,
    ),
    BillCategoryInfo(
      name: 'Government',
      icon: Icons.account_balance,
      color: Color(0xFF0D47A1),
      category: BillCategory.government,
    ),
    BillCategoryInfo(
      name: 'Others',
      icon: Icons.miscellaneous_services,
      color: Color(0xFF757575),
      category: BillCategory.other,
    ),
  ];

  static String getCategoryName(BillCategory category) {
    final categoryInfo = categories.firstWhere(
      (c) => c.category == category,
      orElse: () => const BillCategoryInfo(
        name: 'Unknown',
        icon: Icons.help_outline,
        color: Colors.grey,
        category: BillCategory.other,
      ),
    );
    return categoryInfo.name;
  }

  static IconData getCategoryIcon(BillCategory category) {
    final categoryInfo = categories.firstWhere(
      (c) => c.category == category,
      orElse: () => const BillCategoryInfo(
        name: 'Unknown',
        icon: Icons.help_outline,
        color: Colors.grey,
        category: BillCategory.other,
      ),
    );
    return categoryInfo.icon;
  }

  static Color getCategoryColor(BillCategory category) {
    final categoryInfo = categories.firstWhere(
      (c) => c.category == category,
      orElse: () => const BillCategoryInfo(
        name: 'Unknown',
        icon: Icons.help_outline,
        color: Colors.grey,
        category: BillCategory.other,
      ),
    );
    return categoryInfo.color;
  }
}

// Transaction Types
class TransactionTypes {
  static const Map<String, IconData> icons = {
    'transfer': Icons.arrow_upward,
    'deposit': Icons.arrow_downward,
    'withdrawal': Icons.account_balance_wallet_outlined,
    'bill_payment': Icons.receipt_long,
    'airtime_purchase': Icons.phone_android,
    'data_purchase': Icons.wifi,
    'receive_money': Icons.arrow_downward,
  };

  static IconData getIcon(String type) {
    return icons[type] ?? Icons.swap_horiz;
  }
}

// Bank List for Nigeria
class Bank {
  final String name;
  final String code;
  final String? logoUrl;

  const Bank({
    required this.name,
    required this.code,
    this.logoUrl,
  });
}

class NigerianBanks {
  // This is a sample list of Nigerian banks
  // In a real app, this would come from the API
  static const List<Bank> banks = [
    Bank(name: 'Access Bank', code: '044'),
    Bank(name: 'Citibank Nigeria', code: '023'),
    Bank(name: 'Ecobank Nigeria', code: '050'),
    Bank(name: 'Fidelity Bank', code: '070'),
    Bank(name: 'First Bank of Nigeria', code: '011'),
    Bank(name: 'First City Monument Bank', code: '214'),
    Bank(name: 'Guaranty Trust Bank', code: '058'),
    Bank(name: 'Heritage Bank', code: '030'),
    Bank(name: 'Keystone Bank', code: '082'),
    Bank(name: 'Polaris Bank', code: '076'),
    Bank(name: 'Stanbic IBTC Bank', code: '221'),
    Bank(name: 'Standard Chartered Bank', code: '068'),
    Bank(name: 'Sterling Bank', code: '232'),
    Bank(name: 'Union Bank of Nigeria', code: '032'),
    Bank(name: 'United Bank for Africa', code: '033'),
    Bank(name: 'Unity Bank', code: '215'),
    Bank(name: 'Wema Bank', code: '035'),
    Bank(name: 'Zenith Bank', code: '057'),
  ];

  static Bank getBank(String code) {
    return banks.firstWhere(
      (bank) => bank.code == code,
      orElse: () => const Bank(
        name: 'Unknown Bank',
        code: '000',
      ),
    );
  }
}
