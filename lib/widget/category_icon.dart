import 'package:flutter/material.dart';
import 'package:financeapp/core/app_color.dart';
import 'package:financeapp/model/category_model.dart';

/// A horizontally-scrollable row of category icon chips.
///
/// Usage:
/// ```dart
/// CategoryIconList(
///   categories: kDefaultCategories,
///   selectedId: _selectedCategory?.name,
///   onSelected: (cat) => setState(() => _selectedCategory = cat),
/// )
/// ```
class CategoryIconList extends StatelessWidget {
  final List<CategoryModel> categories;

  /// The [CategoryModel.name] of the currently selected item, or null for none.
  final String? selectedId;

  final ValueChanged<CategoryModel> onSelected;

  /// If true the list scrolls horizontally (default).
  /// If false it wraps in a [Wrap] (useful for full-screen pickers).
  final bool scrollable;

  const CategoryIconList({
    super.key,
    required this.categories,
    required this.onSelected,
    this.selectedId,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) => _CategoryChip(
            category: categories[index],
            isSelected: categories[index].name == selectedId,
            onTap: () => onSelected(categories[index]),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: categories
            .map(
              (cat) => _CategoryChip(
                category: cat,
                isSelected: cat.name == selectedId,
                onTap: () => onSelected(cat),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Single chip ───────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = category.colorValue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon bubble ──────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.25)
                    : AppColor.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : AppColor.card,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                category.iconData,
                color: isSelected ? color : AppColor.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            // ── Label ────────────────────────────────────────────────
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? color : AppColor.textSecondary,
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full-screen category picker bottom sheet ──────────────────────────────────

/// Shows a modal bottom sheet with all [categories] laid out in a [Wrap].
/// Returns the selected [CategoryModel], or null if dismissed.
Future<CategoryModel?> showCategoryPicker({
  required BuildContext context,
  required List<CategoryModel> categories,
  CategoryModel? current,
}) {
  return showModalBottomSheet<CategoryModel>(
    context: context,
    backgroundColor: AppColor.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CategoryPickerSheet(
      categories: categories,
      current: current,
    ),
  );
}

class _CategoryPickerSheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final CategoryModel? current;

  const _CategoryPickerSheet({required this.categories, this.current});

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  late CategoryModel? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.card,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Category',
                style: TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Grid of chips
            CategoryIconList(
              categories: widget.categories,
              selectedId: _selected?.name,
              scrollable: false,
              onSelected: (cat) {
                setState(() => _selected = cat);
                // Small delay so the selection animation plays before closing
                final nav = Navigator.of(context);
                Future.delayed(
                  const Duration(milliseconds: 180),
                  () => nav.pop(cat),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
