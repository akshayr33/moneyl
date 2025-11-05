import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
class AddEditTransactionScreen extends StatefulWidget {
  const AddEditTransactionScreen({super.key});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedType = 'Expense';
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();

  TransactionModel? _editingTransaction;
  int? _editingKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _loadTransactionForEditing(args);
      }
    });
  }

  void _loadTransactionForEditing(int key) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final transaction = transactionProvider.transactions.firstWhere(
      (t) => t.key == key,
      orElse: () => TransactionModel(
        id: '',
        type: 'Expense',
        category: '',
        amount: 0,
        date: DateTime.now(),
      ),
    );

    if (transaction.id.isNotEmpty) {
      _editingTransaction = transaction;
      _editingKey = key;
      _selectedType = transaction.type;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final categories = _selectedType == 'Income'
        ? categoryProvider.getIncomeCategories()
        : categoryProvider.getExpenseCategories();

    if (categories.isNotEmpty && _selectedCategory.isEmpty) {
      _selectedCategory = categories.first.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingTransaction == null ? 'Add Transaction' : 'Edit Transaction'),
        actions: [
          if (_editingTransaction != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Transaction'),
                    content: const Text('Are you sure you want to delete this transaction?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          transactionProvider.deleteTransaction(_editingKey!);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Type Selection
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'Expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment<String>(
                    value: 'Income',
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _selectedCategory = '';
                  });
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  ...categories.map((category) {
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
                  }),
                  const DropdownMenuItem<String>(
                    value: 'add_new',
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 8),
                        Text('Add New Category'),
                      ],
                    ),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue == 'add_new') {
                    _showAddCategoryDialog();
                  } else if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: () => _saveTransaction(transactionProvider),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_editingTransaction == null ? 'Add Transaction' : 'Update Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddCategoryDialog() {
  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
  final newCategoryController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add New Category'),
      content: TextFormField(
        controller: newCategoryController,
        decoration: const InputDecoration(
          labelText: 'Category Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = newCategoryController.text.trim();
            if (name.isNotEmpty) {
              final newCategory = CategoryModel(
                name: name,
                type: _selectedType,
                icon: '💰',
                isDefault: false,
              );
              categoryProvider.addCategory(newCategory);
              setState(() {
                _selectedCategory = name;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category added successfully')),
              );
            }
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}


 void _saveTransaction(TransactionProvider transactionProvider) {
  if (_formKey.currentState!.validate()) {
    // 🔹 Step 1: get the category provider to access category info
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    // 🔹 Step 2: find the selected category model so we can copy its emoji/icon
    final selectedCategoryModel = categoryProvider.categories.firstWhere(
      (c) => c.name == _selectedCategory && c.type == _selectedType,
      orElse: () => CategoryModel(
        name: _selectedCategory,
        type: _selectedType,
        icon: '💰', // fallback if not found
      ),
    );

    // 🔹 Step 3: create the transaction with icon included
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      category: _selectedCategory,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      icon: selectedCategoryModel.icon, // ✅ fixed line
    );

    // 🔹 Step 4: save or update transaction
    if (_editingTransaction != null) {
      transactionProvider.updateTransaction(_editingKey!, transaction);
    } else {
      transactionProvider.addTransaction(transaction);
    }

    // 🔹 Step 5: go back after saving
    Navigator.pop(context);
  }
}


  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}