import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/budget_model.dart';
import '../widgets/budget_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _limitController = TextEditingController();
  String _selectedCategory = '';
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final expenseCategories = categoryProvider.getExpenseCategories();

    if (expenseCategories.isNotEmpty && _selectedCategory.isEmpty) {
      _selectedCategory = expenseCategories.first.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planner'),
      ),
      body: Column(
        children: [
          // Add Budget Form
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Set Monthly Budget',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: expenseCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.name,
                        child: Row(
                          children: [
                            Text(category.icon ?? '💰'),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Month Selection
                  InkWell(
                    onTap: () => _selectMonth(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedMonth.month}/${_selectedMonth.year}',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Limit Input
                  TextFormField(
                    controller: _limitController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Limit',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Set Budget Button
                  ElevatedButton(
                    onPressed: () => _setBudget(budgetProvider),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Set Budget'),
                  ),
                ],
              ),
            ),
          ),

          // Budget List
          Expanded(
            child: budgetProvider.budgets.isEmpty
                ? const Center(
                    child: Text('No budgets set'),
                  )
                : ListView.builder(
                    itemCount: budgetProvider.budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgetProvider.budgets[index];
                      final spent = budgetProvider.getSpentAmount(
                        budget.category,
                        budget.month,
                        transactionProvider,
                      );

                      return BudgetCard(
                        budget: budget,
                        spent: spent,
                        onEdit: () => _editBudget(budget),
                        onDelete: () => budgetProvider.deleteBudget(budget.key!),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _setBudget(BudgetProvider budgetProvider) {
    final limit = double.tryParse(_limitController.text);
    if (limit != null && limit > 0 && _selectedCategory.isNotEmpty) {
      final budget = BudgetModel(
        category: _selectedCategory,
        limit: limit,
        month: DateTime(_selectedMonth.year, _selectedMonth.month),
      );

      budgetProvider.setBudget(budget);
      
      _limitController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget set successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget')),
      );
    }
  }

  void _editBudget(BudgetModel budget) {
    _selectedCategory = budget.category;
    _selectedMonth = budget.month;
    _limitController.text = budget.limit.toString();
    
    // Scroll to top to show the form
    PrimaryScrollController.of(context).animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}