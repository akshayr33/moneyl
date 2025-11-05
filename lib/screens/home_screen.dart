import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyLog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildSummaryCard(
                  context,
                  'Balance',
                  transactionProvider.getBalance(),
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildSummaryCard(
                  context,
                  'Income',
                  transactionProvider.getTotalIncome(),
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildSummaryCard(
                  context,
                  'Expense',
                  transactionProvider.getTotalExpense(),
                  Colors.red,
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Day', 'Week', 'Month', 'All'].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: transactionProvider.currentFilter == filter,
                      onSelected: (selected) {
                        transactionProvider.setFilter(filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Clear Filter button (only when date range active)
          if (transactionProvider.isDateFiltered)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => transactionProvider.clearDateRangeFilter(),
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filter'),
              ),
            ),

          const SizedBox(height: 16),

          // Recent Transactions Header
          // Recent Transactions Header (🗓️ icon moved to right side)
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        'Recent Transactions',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Tooltip(
        message: 'Sort by Date Range',
        child: IconButton(
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              Provider.of<TransactionProvider>(context, listen: false)
                  .filterByDateRange(picked.start, picked.end);
            }
          },
        ),
      ),
    ],
  ),
),

          // ✅ Grouped Transaction List with Edit/Delete
          Expanded(
            child: Builder(
              builder: (context) {
                final provider =
                    Provider.of<TransactionProvider>(context, listen: false);

                final transactions = provider.isDateFiltered
                    ? provider.transactionsForRange
                    : provider.getFilteredTransactions();

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions found'),
                  );
                }

                final incomeTx =
                    transactions.where((t) => t.type == 'Income').toList();
                final expenseTx =
                    transactions.where((t) => t.type == 'Expense').toList();

                final totalIncome = provider.isDateFiltered
                    ? provider.totalIncomeForRange
                    : provider.getTotalIncome();
                final totalExpense = provider.isDateFiltered
                    ? provider.totalExpenseForRange
                    : provider.getTotalExpense();

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (incomeTx.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          'Income (₹${totalIncome.toStringAsFixed(2)})',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ),
                      ...incomeTx.map(
                        (t) => ListTile(
                          leading: Text(
                            t.icon ?? '💰',
                            style: const TextStyle(fontSize: 20),
                          ),
                          title: Text(t.category),
                          subtitle: Text(
                            '${t.date.day}/${t.date.month}/${t.date.year}, '
                            '${TimeOfDay.fromDateTime(t.date).format(context)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+₹${t.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                tooltip: 'Edit Transaction',
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/add-edit-transaction',
                                  arguments: t.key,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Transaction',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title:
                                          const Text('Delete Transaction'),
                                      content: const Text(
                                          'Are you sure you want to delete this transaction?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    Provider.of<TransactionProvider>(context,
                                            listen: false)
                                        .deleteTransaction(t.key!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (expenseTx.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          'Expense (₹${totalExpense.toStringAsFixed(2)})',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                      ...expenseTx.map(
                        (t) => ListTile(
                          leading: Text(
                            t.icon ?? '💰',
                            style: const TextStyle(fontSize: 20),
                          ),
                          title: Text(t.category),
                          subtitle: Text(
                            '${t.date.day}/${t.date.month}/${t.date.year}, '
                            '${TimeOfDay.fromDateTime(t.date).format(context)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '-₹${t.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                tooltip: 'Edit Transaction',
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/add-edit-transaction',
                                  arguments: t.key,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Transaction',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title:
                                          const Text('Delete Transaction'),
                                      content: const Text(
                                          'Are you sure you want to delete this transaction?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    Provider.of<TransactionProvider>(context,
                                            listen: false)
                                        .deleteTransaction(t.key!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/add-edit-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, double amount, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
