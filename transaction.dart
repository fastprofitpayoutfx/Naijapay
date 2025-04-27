enum TransactionType {
  transfer,
  deposit,
  withdrawal,
  billPayment,
  airtimePurchase,
  dataPurchase,
  receiveMoney,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  reversed,
}

class Transaction {
  final String id;
  final String reference;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String description;
  final String recipientName;
  final String recipientAccountNumber;
  final String recipientBankName;
  final String senderName;
  final String senderAccountNumber;
  final String senderBankName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final double? fee;
  final String? category;
  final String? billReference;
  final String? narration;

  Transaction({
    required this.id,
    required this.reference,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.recipientName,
    required this.recipientAccountNumber,
    required this.recipientBankName,
    required this.senderName,
    required this.senderAccountNumber,
    required this.senderBankName,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.fee,
    this.category,
    this.billReference,
    this.narration,
  });

  bool get isIncoming {
    return type == TransactionType.receiveMoney || type == TransactionType.deposit;
  }

  bool get isOutgoing {
    return !isIncoming;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: _getTransactionType(json['type']),
      status: _getTransactionStatus(json['status']),
      description: json['description'] ?? '',
      recipientName: json['recipient_name'] ?? '',
      recipientAccountNumber: json['recipient_account_number'] ?? '',
      recipientBankName: json['recipient_bank_name'] ?? '',
      senderName: json['sender_name'] ?? '',
      senderAccountNumber: json['sender_account_number'] ?? '',
      senderBankName: json['sender_bank_name'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      failureReason: json['failure_reason'],
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
      category: json['category'],
      billReference: json['bill_reference'],
      narration: json['narration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'amount': amount,
      'type': _getTransactionTypeString(type),
      'status': _getTransactionStatusString(status),
      'description': description,
      'recipient_name': recipientName,
      'recipient_account_number': recipientAccountNumber,
      'recipient_bank_name': recipientBankName,
      'sender_name': senderName,
      'sender_account_number': senderAccountNumber,
      'sender_bank_name': senderBankName,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'failure_reason': failureReason,
      'fee': fee,
      'category': category,
      'bill_reference': billReference,
      'narration': narration,
    };
  }

  static TransactionType _getTransactionType(String? type) {
    switch (type) {
      case 'transfer':
        return TransactionType.transfer;
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'bill_payment':
        return TransactionType.billPayment;
      case 'airtime_purchase':
        return TransactionType.airtimePurchase;
      case 'data_purchase':
        return TransactionType.dataPurchase;
      case 'receive_money':
        return TransactionType.receiveMoney;
      default:
        return TransactionType.transfer;
    }
  }

  static String _getTransactionTypeString(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return 'transfer';
      case TransactionType.deposit:
        return 'deposit';
      case TransactionType.withdrawal:
        return 'withdrawal';
      case TransactionType.billPayment:
        return 'bill_payment';
      case TransactionType.airtimePurchase:
        return 'airtime_purchase';
      case TransactionType.dataPurchase:
        return 'data_purchase';
      case TransactionType.receiveMoney:
        return 'receive_money';
    }
  }

  static TransactionStatus _getTransactionStatus(String? status) {
    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'reversed':
        return TransactionStatus.reversed;
      default:
        return TransactionStatus.pending;
    }
  }

  static String _getTransactionStatusString(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.completed:
        return 'completed';
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.reversed:
        return 'reversed';
    }
  }
}
