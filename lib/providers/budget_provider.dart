import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/budget_model.dart';
import '../providers/transaction_provider.dart';

class BudgetProvider with ChangeNotifier {
  late Box<BudgetModel> _budgetsBox;
  List<BudgetModel> _budgets = [];
  List<BudgetModel> get budgets => _budgets;

  BudgetProvider() {
    _init();
  }

  Future<void> _init() async {
    _budgetsBox = await Hive.openBox<BudgetModel>('budgets');
    _budgets = _budgetsBox.values.toList();
    notifyListeners();
  }

  BudgetModel? getBudgetForCategory(String category, DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    return _budgets.firstWhere(
      (b) => b.category == category && b.month.isAtSameMomentAs(firstDay),
      orElse: () => BudgetModel(category: '', limit: 0, month: DateTime.now()),
    );
  }

  double getSpentAmount(String category, DateTime month, TransactionProvider transactionProvider) {
    final transactions = transactionProvider.transactions.where((t) =>
      t.category == category &&
      t.type == 'Expense' &&
      t.date.year == month.year &&
      t.date.month == month.month
    ).toList();
    
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> setBudget(BudgetModel budget) async {
    final existingIndex = _budgets.indexWhere((b) =>
      b.category == budget.category && 
      b.month.isAtSameMomentAs(budget.month)
    );

    if (existingIndex != -1) {
      await _budgetsBox.putAt(existingIndex, budget);
      _budgets[existingIndex] = budget;
    } else {
      await _budgetsBox.add(budget);
      _budgets.add(budget);
    }
    
    notifyListeners();
  }

  Future<void> deleteBudget(int key) async {
    await _budgetsBox.delete(key);
    _budgets.removeWhere((b) => b.key == key);
    notifyListeners();
  }

  Future<void> clearAllBudgets() async {
    await _budgetsBox.clear();
    _budgets.clear();
    notifyListeners();
  }
}