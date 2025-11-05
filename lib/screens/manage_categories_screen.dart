import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'Expense';

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Column(
        children: [
          // Add Category Form
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Add New Category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Type Selection
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'Expense',
                        label: Text('Expense'),
                      ),
                      ButtonSegment<String>(
                        value: 'Income',
                        label: Text('Income'),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedType = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Name Input
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add Button
                  ElevatedButton(
                    onPressed: () => _addCategory(categoryProvider),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Add Category'),
                  ),
                ],
              ),
            ),
          ),

          // Categories List
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Expense Categories'),
                      Tab(text: 'Income Categories'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCategoryList(categoryProvider.getExpenseCategories(), categoryProvider),
                        _buildCategoryList(categoryProvider.getIncomeCategories(), categoryProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> categories, CategoryProvider categoryProvider) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(category.icon ?? '💰'),
            ),
            title: Text(category.name),
            trailing: category.isDefault
                ? const Text('Default', style: TextStyle(color: Colors.grey))
                : IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                   onPressed: () => _deleteCategory(category.key!, categoryProvider),

                  ),
          ),
        );
      },
    );
  }

  void _addCategory(CategoryProvider categoryProvider) {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final category = CategoryModel(
        name: name,
        type: _selectedType,
        icon: '💰',
      );

      categoryProvider.addCategory(category);
      _nameController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added successfully')),
      );
    }else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a category name')),
    );
  }
  }

   void _deleteCategory(int key, CategoryProvider categoryProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              categoryProvider.deleteCategoryByKey(key);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}