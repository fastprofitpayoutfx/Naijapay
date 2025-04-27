import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/transaction.dart';
import '../services/payment_service.dart';
import '../widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filters = ['All', 'Income', 'Expense', 'Failed'];
  int _selectedFilterIndex = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load transactions if empty
    Future.delayed(Duration.zero, () {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      if (paymentService.recentTransactions.isEmpty) {
        paymentService.getRecentTransactions();
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedFilterIndex = _tabController.index;
      });
    }
  }

  Future<void> _refreshTransactions() async {
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    await paymentService.getRecentTransactions();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'SELECT DATE RANGE',
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.primaryTextColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    List<Transaction> filteredList = List.from(transactions);
    
    // Filter by tab
    if (_selectedFilterIndex > 0) {
      if (_filters[_selectedFilterIndex] == 'Income') {
        filteredList = filteredList.where((t) => t.isIncoming).toList();
      } else if (_filters[_selectedFilterIndex] == 'Expense') {
        filteredList = filteredList.where((t) => t.isOutgoing).toList();
      } else if (_filters[_selectedFilterIndex] == 'Failed') {
        filteredList = filteredList.where((t) => t.status == TransactionStatus.failed).toList();
      }
    }
    
    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filteredList = filteredList.where((t) {
        return (t.createdAt.isAfter(_startDate!) || t.createdAt.isAtSameMomentAs(_startDate!)) && 
               (t.createdAt.isBefore(_endDate!.add(const Duration(days: 1))) || t.createdAt.isAtSameMomentAs(_endDate!));
      }).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList = filteredList.where((t) {
        return t.description.toLowerCase().contains(query) ||
               t.recipientName.toLowerCase().contains(query) ||
               t.recipientAccountNumber.toLowerCase().contains(query) ||
               t.reference.toLowerCase().contains(query);
      }).toList();
    }
    
    return filteredList;
  }

  String _formatDateRange() {
    if (_startDate == null || _endDate == null) return 'All Time';
    
    final dateFormat = DateFormat('MMM d, yyyy');
    return '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    final paymentService = Provider.of<PaymentService>(context);
    final isLoading = paymentService.isLoading;
    final transactions = paymentService.recentTransactions;
    final filteredTransactions = _filterTransactions(transactions);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterBottomSheet,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: _filters.map((filter) => Tab(text: filter)).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: Column(
          children: [
            // Date filter pill if active
            if (_startDate != null && _endDate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateRange(),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _clearFilters,
                      child: const Icon(Icons.close, size: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            
            // Transactions list
            Expanded(
              child: isLoading && transactions.isEmpty
                  ? _buildLoadingShimmer()
                  : filteredTransactions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            
                            // Add date header if it's a new day
                            if (index == 0 || !_isSameDay(
                                filteredTransactions[index - 1].createdAt,
                                transaction.createdAt)) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDateHeader(transaction.createdAt),
                                  TransactionCard(transaction: transaction),
                                ],
                              );
                            }
                            
                            return TransactionCard(transaction: transaction);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Filter Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Date Range Filter
                  const Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      await _selectDateRange();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            _formatDateRange(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Apply Filters Button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _clearFilters();
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppTheme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          if (index % 4 == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  margin: const EdgeInsets.only(bottom: 16, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            );
          }
          
          return Container(
            width: double.infinity,
            height: 80,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Transactions will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _startDate != null)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _startDate = null;
                  _endDate = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (dateToCheck == today) {
      dateText = 'Today';
    } else if (dateToCheck == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('EEEE, MMMM d, y').format(date);
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        dateText,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.secondaryTextColor,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
