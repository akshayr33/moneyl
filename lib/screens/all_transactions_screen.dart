import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final filteredTransactions = transactionProvider.getFilteredTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
      ),
      body: Column(
        children: [
          // Summary Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Total Income',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '\$${transactionProvider.getTotalIncome().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Total Expense',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '\$${transactionProvider.getTotalExpense().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Day', 'Week', 'Month', 'Year', 'All'].map((filter) {
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

          // Transactions List
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(
                    child: Text('No transactions found'),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return TransactionTile(
                        transaction: transaction,
                        onEdit: () => Navigator.pushNamed(
                          context,
                          '/add-edit-transaction',
                          arguments: transaction.key,
                        ),
                        onDelete: () => transactionProvider.deleteTransaction(transaction.key!),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}