import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  late Box<CategoryModel> _categoriesBox;
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  CategoryProvider() {
    _init();
  }

  Future<void> _init() async {
    _categoriesBox = await Hive.openBox<CategoryModel>('categories');
    
    if (_categoriesBox.isEmpty) {
      await _initializeDefaultCategories();
    }
    
    _categories = _categoriesBox.values.toList();
    notifyListeners();
  }

  Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      // Expense Categories
      CategoryModel(name: 'Food', type: 'Expense', icon: '🍔', isDefault: true),
      CategoryModel(name: 'Shopping', type: 'Expense', icon: '🛍️', isDefault: true),
      CategoryModel(name: 'Transport', type: 'Expense', icon: '🚗', isDefault: true),
      CategoryModel(name: 'Bills', type: 'Expense', icon: '💡', isDefault: true),
      CategoryModel(name: 'Entertainment', type: 'Expense', icon: '🎬', isDefault: true),
      CategoryModel(name: 'Healthcare', type: 'Expense', icon: '💊', isDefault: true),
      CategoryModel(name: 'Education', type: 'Expense', icon: '🎓', isDefault: true),
      CategoryModel(name: 'Rent', type: 'Expense', icon: '🏠', isDefault: true),
      CategoryModel(name: 'Other', type: 'Expense', icon: '💼', isDefault: true),
      
      // Income Categories
      CategoryModel(name: 'Salary', type: 'Income', icon: '💵', isDefault: true),
      CategoryModel(name: 'Freelance', type: 'Income', icon: '💻', isDefault: true),
      CategoryModel(name: 'Investment', type: 'Income', icon: '📈', isDefault: true),
      CategoryModel(name: 'Gift', type: 'Income', icon: '🎁', isDefault: true),
      CategoryModel(name: 'Other', type: 'Income', icon: '💼', isDefault: true),
    ];

    for (final category in defaultCategories) {
      await _categoriesBox.add(category);
    }
  }

  List<CategoryModel> getExpenseCategories() {
    return _categories.where((c) => c.type == 'Expense').toList();
  }

  List<CategoryModel> getIncomeCategories() {
    return _categories.where((c) => c.type == 'Income').toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoriesBox.add(category);
    _categories.add(category);
    notifyListeners();
  }

  Future<void> updateCategory(int key, CategoryModel category) async {
    await _categoriesBox.put(key, category);
    final index = _categories.indexWhere((c) => c.key == key);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

Future<void> deleteCategory(CategoryModel category) async {
  final box = await Hive.openBox<CategoryModel>('categories');

  // Find the key for this category
  final keyToDelete = box.keys.cast<dynamic>().firstWhere(
    (key) {
      final c = box.get(key);
      return c?.name == category.name && c?.type == category.type;
    },
    orElse: () => null,
  );

  if (keyToDelete != null) {
    await box.delete(keyToDelete);
    _categories.removeWhere(
      (c) => c.name == category.name && c.type == category.type,
    );
    notifyListeners();
  }
}
Future<void> deleteCategoryByKey(dynamic key) async {
  final box = await Hive.openBox<CategoryModel>('categories');

  await box.delete(key);
  _categories = box.values.toList();

  notifyListeners();
}



  Future<void> clearAllCategories() async {
    await _categoriesBox.clear();
    await _initializeDefaultCategories();
    _categories = _categoriesBox.values.toList();
    notifyListeners();
  }
}