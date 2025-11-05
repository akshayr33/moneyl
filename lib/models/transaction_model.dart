import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String type; // 'Income' or 'Expense'
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final double amount;
  
  @HiveField(4)
  final DateTime date;
  
  @HiveField(5)
  final String? note;
  
  @HiveField(6)
  final String? icon;

  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
    this.icon,
  });
}