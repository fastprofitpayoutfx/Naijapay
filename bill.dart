enum BillCategory {
  electricity,
  water,
  internet,
  tv,
  education,
  government,
  other
}

class BillProvider {
  final String id;
  final String name;
  final String logoUrl;
  final BillCategory category;
  final String? description;
  final bool isPopular;

  BillProvider({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.category,
    this.description,
    this.isPopular = false,
  });

  factory BillProvider.fromJson(Map<String, dynamic> json) {
    return BillProvider(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      category: _getBillCategory(json['category']),
      description: json['description'],
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'category': _getBillCategoryString(category),
      'description': description,
      'is_popular': isPopular,
    };
  }

  static BillCategory _getBillCategory(String? category) {
    switch (category) {
      case 'electricity':
        return BillCategory.electricity;
      case 'water':
        return BillCategory.water;
      case 'internet':
        return BillCategory.internet;
      case 'tv':
        return BillCategory.tv;
      case 'education':
        return BillCategory.education;
      case 'government':
        return BillCategory.government;
      default:
        return BillCategory.other;
    }
  }

  static String _getBillCategoryString(BillCategory category) {
    switch (category) {
      case BillCategory.electricity:
        return 'electricity';
      case BillCategory.water:
        return 'water';
      case BillCategory.internet:
        return 'internet';
      case BillCategory.tv:
        return 'tv';
      case BillCategory.education:
        return 'education';
      case BillCategory.government:
        return 'government';
      case BillCategory.other:
        return 'other';
    }
  }
}

class BillCustomerValidation {
  final String customerId;
  final String customerName;
  final String customerAddress;
  final String? customerType;
  final String? balance;
  final String? dueDate;
  final String? minimumAmount;
  final String? maximumAmount;

  BillCustomerValidation({
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    this.customerType,
    this.balance,
    this.dueDate,
    this.minimumAmount,
    this.maximumAmount,
  });

  factory BillCustomerValidation.fromJson(Map<String, dynamic> json) {
    return BillCustomerValidation(
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerAddress: json['customer_address'] ?? '',
      customerType: json['customer_type'],
      balance: json['balance'],
      dueDate: json['due_date'],
      minimumAmount: json['minimum_amount'],
      maximumAmount: json['maximum_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'customer_type': customerType,
      'balance': balance,
      'due_date': dueDate,
      'minimum_amount': minimumAmount,
      'maximum_amount': maximumAmount,
    };
  }
}

class BillPayment {
  final String id;
  final String reference;
  final String providerId;
  final String providerName;
  final String customerId;
  final String customerName;
  final double amount;
  final double fee;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? receiptNumber;
  final String? failureReason;

  BillPayment({
    required this.id,
    required this.reference,
    required this.providerId,
    required this.providerName,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.receiptNumber,
    this.failureReason,
  });

  factory BillPayment.fromJson(Map<String, dynamic> json) {
    return BillPayment(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      providerId: json['provider_id'] ?? '',
      providerName: json['provider_name'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      fee: (json['fee'] ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      receiptNumber: json['receipt_number'],
      failureReason: json['failure_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'provider_id': providerId,
      'provider_name': providerName,
      'customer_id': customerId,
      'customer_name': customerName,
      'amount': amount,
      'fee': fee,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'receipt_number': receiptNumber,
      'failure_reason': failureReason,
    };
  }
}
