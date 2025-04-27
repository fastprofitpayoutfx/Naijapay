import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/transaction.dart';
import '../utils/helpers.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (transaction.status) {
      case TransactionStatus.completed:
        return AppTheme.successColor;
      case TransactionStatus.pending:
        return AppTheme.warningColor;
      case TransactionStatus.failed:
        return AppTheme.errorColor;
      case TransactionStatus.reversed:
        return AppTheme.infoColor;
      default:
        return AppTheme.secondaryTextColor;
    }
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.transfer:
        return Icons.arrow_upward;
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.account_balance_wallet_outlined;
      case TransactionType.billPayment:
        return Icons.receipt_long;
      case TransactionType.airtimePurchase:
        return Icons.phone_android;
      case TransactionType.dataPurchase:
        return Icons.wifi;
      case TransactionType.receiveMoney:
        return Icons.arrow_downward;
      default:
        return Icons.swap_horiz;
    }
  }

  String _getTransactionTitle() {
    switch (transaction.type) {
      case TransactionType.transfer:
        return 'Transfer to ${transaction.recipientName}';
      case TransactionType.deposit:
        return 'Deposit from ${transaction.senderName}';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.billPayment:
        return 'Bill Payment';
      case TransactionType.airtimePurchase:
        return 'Airtime Purchase';
      case TransactionType.dataPurchase:
        return 'Data Purchase';
      case TransactionType.receiveMoney:
        return 'Money Received from ${transaction.senderName}';
      default:
        return transaction.description;
    }
  }

  String _getTransactionSubtitle() {
    String timeStr = DateFormat('hh:mm a').format(transaction.createdAt);
    
    switch (transaction.type) {
      case TransactionType.transfer:
        return '${transaction.recipientBankName} • ${transaction.recipientAccountNumber} • $timeStr';
      case TransactionType.billPayment:
        return 'Ref: ${transaction.reference.substring(0, 8)}... • $timeStr';
      case TransactionType.airtimePurchase:
      case TransactionType.dataPurchase:
        // Return recipient name or account number depending on what's available
        return transaction.recipientName.isNotEmpty
            ? '${transaction.recipientName} • $timeStr'
            : '${transaction.recipientAccountNumber} • $timeStr';
      default:
        return 'Ref: ${transaction.reference.substring(0, 8)}... • $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.isIncoming;
    final amount = transaction.amount;
    final statusColor = _getStatusColor();
    final transactionIcon = _getTransactionIcon();
    final title = _getTransactionTitle();
    final subtitle = _getTransactionSubtitle();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Transaction Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                transactionIcon,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncoming ? '+' : '-'}₦${formatCurrency(amount)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isIncoming ? AppTheme.successColor : AppTheme.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.status.toString().split('.').last,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
