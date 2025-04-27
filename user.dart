class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String accountNumber;
  final double balance;
  final String bvn;
  final String profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final String bankName;
  final String bankCode;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.accountNumber,
    required this.balance,
    required this.bvn,
    required this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isVerified,
    required this.bankName,
    required this.bankCode,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      accountNumber: json['account_number'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      bvn: json['bvn'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      isVerified: json['is_verified'] ?? false,
      bankName: json['bank_name'] ?? 'NaijaPay Bank',
      bankCode: json['bank_code'] ?? '000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'account_number': accountNumber,
      'balance': balance,
      'bvn': bvn,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_verified': isVerified,
      'bank_name': bankName,
      'bank_code': bankCode,
    };
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? accountNumber,
    double? balance,
    String? bvn,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? bankName,
    String? bankCode,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      bvn: bvn ?? this.bvn,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
    );
  }
}
