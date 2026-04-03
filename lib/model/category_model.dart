import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'income' | 'expense' | 'both'
  final String? icon; // hex codepoint string e.g. '0xe533'
  final String? color; // hex color string e.g. '#FF7043'

  const CategoryModel({
    this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> m) => CategoryModel(
        id: m['id'],
        name: m['name'],
        type: m['type'],
        icon: m['icon'],
        color: m['color'],
      );

  /// Flutter [IconData] from the stored hex codepoint string.
  IconData get iconData => IconData(
        int.parse((icon ?? '0xe145').replaceFirst('0x', ''), radix: 16),
        fontFamily: 'MaterialIcons',
      );

  /// Flutter [Color] from the stored '#RRGGBB' string.
  Color get colorValue {
    final hex = (color ?? '#78909C').replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

// ── Default categories ────────────────────────────────────────────────────────
// These mirror the seed data in DBHelper._seedCategories so the UI can show
// categories even before the first DB read (e.g. on the add-transaction sheet).

const List<CategoryModel> kDefaultCategories = [
  // ── Expense ──
  CategoryModel(
    name: 'Food',
    type: 'expense',
    icon: '0xe533',
    color: '#FF7043',
  ),
  CategoryModel(
    name: 'Transport',
    type: 'expense',
    icon: '0xe531',
    color: '#42A5F5',
  ),
  CategoryModel(
    name: 'Shopping',
    type: 'expense',
    icon: '0xe59c',
    color: '#AB47BC',
  ),
  CategoryModel(
    name: 'Health',
    type: 'expense',
    icon: '0xe3f3',
    color: '#EF5350',
  ),
  CategoryModel(
    name: 'Bills',
    type: 'expense',
    icon: '0xe227',
    color: '#FFA726',
  ),
  CategoryModel(
    name: 'Entertainment',
    type: 'expense',
    icon: '0xe41d',
    color: '#26C6DA',
  ),
  // ── Income ──
  CategoryModel(
    name: 'Salary',
    type: 'income',
    icon: '0xe227',
    color: '#66BB6A',
  ),
  CategoryModel(
    name: 'Freelance',
    type: 'income',
    icon: '0xe7f0',
    color: '#26A69A',
  ),
  CategoryModel(
    name: 'Investment',
    type: 'income',
    icon: '0xe8dc',
    color: '#5C6BC0',
  ),
  CategoryModel(
    name: 'Gift',
    type: 'income',
    icon: '0xe40c',
    color: '#EC407A',
  ),
  // ── Both ──
  CategoryModel(
    name: 'Other',
    type: 'both',
    icon: '0xe145',
    color: '#78909C',
  ),
];
