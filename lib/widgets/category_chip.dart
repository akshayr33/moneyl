import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDelete;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.showDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Icon/Emoji
              Text(
                category.icon ?? '💰',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              
              // Category Name
              Text(
                category.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              // Type Badge (for analysis screen)
              if (onTap == null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.type == 'Income' 
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    category.type == 'Income' ? 'I' : 'E',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: category.type == 'Income' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
              
              // Delete Icon (for management screen)
              if (showDelete && onDelete != null && !category.isDefault) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Category Selection Grid for Add/Edit Transaction Screen
class CategorySelectionGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelectionGrid({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        return CategoryChip(
          category: category,
          isSelected: selectedCategory == category.name,
          onTap: () => onCategorySelected(category.name),
        );
      }).toList(),
    );
  }
}

// Category List Item for Management Screen
class CategoryListItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryListItem({
    super.key,
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.type == 'Income' 
              ? Colors.green.withValues(alpha:0.2)
              : Colors.red.withValues(alpha: 0.2),
          child: Text(
            category.icon ?? '💰',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        title: Text(category.name),
        subtitle: Text(
          category.type,
          style: TextStyle(
            color: category.type == 'Income' ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: category.isDefault
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit Category',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: 'Delete Category',
                    ),
                ],
              ),
      ),
    );
  }
}