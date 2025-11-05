import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String type; // 'Income' or 'Expense'
  
  @HiveField(2)
  final String? icon;
  
  @HiveField(3)
  final bool isDefault;

  CategoryModel({
    required this.name,
    required this.type,
    this.icon,
    this.isDefault = false,
  });
}