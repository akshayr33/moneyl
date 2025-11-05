import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

import '../models/transaction_model.dart';
import '../widgets/pie_chart_widget.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
  

    // Get all transactions
    final allTransactions = transactionProvider.transactions;
    final expenses = allTransactions.where((t) => t.type == 'Expense').toList();
    final incomes = allTransactions.where((t) => t.type == 'Income').toList();

    // Group by category
    final expenseByCategory = _groupByCategory(expenses);
    final incomeByCategory = _groupByCategory(incomes);

    final totalIncome = _calculateTotal(incomes);
    final totalExpense = _calculateTotal(expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Income vs Expense Comparison
            if (totalIncome > 0 || totalExpense > 0)
              PieChartWidget(
                data: {
                  'Income': totalIncome,
                  'Expense': totalExpense,
                },
                title: 'Income vs Expense',
              ),

            const SizedBox(height: 16),

            // Expense Breakdown
            if (expenseByCategory.isNotEmpty)
              PieChartWidget(
                data: expenseByCategory,
                title: 'Expense Breakdown',
              ),

            const SizedBox(height: 16),

            // Income Breakdown
            if (incomeByCategory.isNotEmpty)
              PieChartWidget(
                data: incomeByCategory,
                title: 'Income Breakdown',
              ),

            const SizedBox(height: 16),

            // Category Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ..._buildCategorySummary(
                      context,
                      expenseByCategory,
                      incomeByCategory,
                      totalIncome + totalExpense,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fixed method - properly typed
  Map<String, double> _groupByCategory(List<TransactionModel> transactions) {
    final Map<String, double> result = {};
    
    for (final transaction in transactions) {
      result.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    
    return result;
  }

  // Helper method to calculate total
  double _calculateTotal(List<TransactionModel> transactions) {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  List<Widget> _buildCategorySummary(
    BuildContext context,
    Map<String, double> expenses,
    Map<String, double> incomes,
    double total,
  ) {
    final allCategories = {...expenses.keys, ...incomes.keys};
    final widgets = <Widget>[];

    for (final category in allCategories) {
      final expense = expenses[category] ?? 0;
      final income = incomes[category] ?? 0;
      final totalAmount = expense + income;
      final percentage = total > 0 ? (totalAmount / total * 100) : 0;

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '(${percentage.toStringAsFixed(1)}%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }
}