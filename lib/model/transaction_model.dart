class FinanceTransaction {
  final String id;
  final String type;
  final int categoryId; // FK to categories
  final double amount;
  final String date;
  final String notes;
  final String? createdAt;

  FinanceTransaction({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.notes = '',
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'category_id': categoryId,
    'amount': amount,
    'date': date,
    'notes': notes,
  };

  factory FinanceTransaction.fromMap(Map<String, dynamic> m) =>
      FinanceTransaction(
        id: m['id'],
        type: m['type'],
        categoryId: m['category_id'],
        amount: m['amount'],
        date: m['date'],
        notes: m['notes'] ?? '',
        createdAt: m['created_at'],
      );
}
