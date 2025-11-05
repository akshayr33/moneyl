import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  late Box<TransactionModel> _transactionsBox;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;
  bool get isDateFiltered => _filterStartDate != null && _filterEndDate != null;  /*now addwd*/


  String _currentFilter = 'All';
  String get currentFilter => _currentFilter;

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;


  TransactionProvider() {
    _init();
  }

  Future<void> _init() async {
    _transactionsBox = await Hive.openBox<TransactionModel>('transactions');
    _transactions = _transactionsBox.values.toList();
    _sortTransactions();
    notifyListeners();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<TransactionModel> getFilteredTransactions() {
    final now = DateTime.now();
    switch (_currentFilter) {
      case 'Day':
        return _transactions.where((t) => 
          t.date.year == now.year && 
          t.date.month == now.month && 
          t.date.day == now.day
        ).toList();
      case 'Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return _transactions.where((t) => 
          t.date.isAfter(startOfWeek.subtract(const Duration(days: 1)))
        ).toList();
      case 'Month':
        return _transactions.where((t) => 
          t.date.year == now.year && 
          t.date.month == now.month
        ).toList();
       /*year*/
        default:
        return _transactions;
    }
  }

  List<TransactionModel> getRecentTransactions(int count) {
    final filtered = getFilteredTransactions();
    return filtered.take(count).toList();
  }

  double getTotalIncome() {
    return getFilteredTransactions()
        .where((t) => t.type == 'Income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense() {
    return getFilteredTransactions()
        .where((t) => t.type == 'Expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getBalance() {
    return getTotalIncome() - getTotalExpense();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsBox.add(transaction);
    _transactions.add(transaction);
    _sortTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(int key, TransactionModel transaction) async {
    await _transactionsBox.put(key, transaction);
    final index = _transactions.indexWhere((t) => t.key == key);
    if (index != -1) {
      _transactions[index] = transaction;
      _sortTransactions();
      notifyListeners();
    }
  }

Future<void> deleteTransaction(dynamic key) async {
  await _transactionsBox.delete(key);

  // 🔄 Rebuild the list directly from Hive with preserved keys
  _transactions = List.generate(_transactionsBox.length, (index) {
    final transaction = _transactionsBox.getAt(index)!;
    return transaction;
  });

  _sortTransactions(); // keep sorted order
  notifyListeners();
}


  Future<void> clearAllTransactions() async {
    await _transactionsBox.clear();
    _transactions.clear();
    notifyListeners();
  }

/*4*/
/// Apply a custom date-range filter (date-only; ignores time)
void filterByDateRange(DateTime start, DateTime end) {
  _filterStartDate = DateTime(start.year, start.month, start.day);
  _filterEndDate = DateTime(end.year, end.month, end.day);
  notifyListeners();
}

/// Clear any active date-range filter
void clearDateRangeFilter() {
  _filterStartDate = null;
  _filterEndDate = null;
  notifyListeners();
}

/// Return transactions for the active date range (if set)
List<TransactionModel> get transactionsForRange {
  if (!isDateFiltered) return _transactions;

  return _transactions.where((t) {
    final d = DateTime(t.date.year, t.date.month, t.date.day);
    return d.isAfter(_filterStartDate!.subtract(const Duration(days: 1))) &&
           d.isBefore(_filterEndDate!.add(const Duration(days: 1)));
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

/// Total income in selected date range
double get totalIncomeForRange {
  return transactionsForRange
      .where((t) => t.type == 'Income')
      .fold(0.0, (sum, t) => sum + t.amount);
}

/// Total expense in selected date range
double get totalExpenseForRange {
  return transactionsForRange
      .where((t) => t.type == 'Expense')
      .fold(0.0, (sum, t) => sum + t.amount);
}




  void _sortTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }
}