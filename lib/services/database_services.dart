import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  static Database? _db;

  DBHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // ── Init & Create ──────────────────────────────────────────────

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure, // enables foreign keys
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key enforcement in SQLite
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── Categories Table ──
    await db.execute('''
      CREATE TABLE categories (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        name   TEXT    NOT NULL UNIQUE,
        type   TEXT    NOT NULL CHECK(type IN ('income','expense','both')),
        icon   TEXT,
        color  TEXT
      )
    ''');

    // ── Transactions Table ──
    await db.execute('''
      CREATE TABLE transactions (
        id          TEXT    PRIMARY KEY,
        type        TEXT    NOT NULL CHECK(type IN ('income','expense')),
        category_id INTEGER NOT NULL,
        amount      REAL    NOT NULL CHECK(amount > 0),
        date        TEXT    NOT NULL,
        notes       TEXT    DEFAULT '',
        created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (category_id) REFERENCES categories(id)
          ON DELETE RESTRICT
      )
    ''');

    // ── Indexes for fast queries ──
    await db.execute('CREATE INDEX idx_txn_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_txn_type ON transactions(type)');
    await db.execute(
      'CREATE INDEX idx_txn_category ON transactions(category_id)',
    );

    // ── Seed default categories ──
    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    final categories = [
      // Expense categories
      {'name': 'Food', 'type': 'expense', 'icon': '0xe533', 'color': '#FF7043'},
      {
        'name': 'Transport',
        'type': 'expense',
        'icon': '0xe531',
        'color': '#42A5F5',
      },
      {
        'name': 'Shopping',
        'type': 'expense',
        'icon': '0xe59c',
        'color': '#AB47BC',
      },
      {
        'name': 'Health',
        'type': 'expense',
        'icon': '0xe3f3',
        'color': '#EF5350',
      },
      {
        'name': 'Bills',
        'type': 'expense',
        'icon': '0xe227',
        'color': '#FFA726',
      },
      {
        'name': 'Entertainment',
        'type': 'expense',
        'icon': '0xe41d',
        'color': '#26C6DA',
      },
      // Income categories
      {
        'name': 'Salary',
        'type': 'income',
        'icon': '0xe227',
        'color': '#66BB6A',
      },
      {
        'name': 'Freelance',
        'type': 'income',
        'icon': '0xe7f0',
        'color': '#26A69A',
      },
      {
        'name': 'Investment',
        'type': 'income',
        'icon': '0xe8dc',
        'color': '#5C6BC0',
      },
      {'name': 'Gift', 'type': 'income', 'icon': '0xe40c', 'color': '#EC407A'},
      // Both
      {'name': 'Other', 'type': 'both', 'icon': '0xe145', 'color': '#78909C'},
    ];

    final batch = db.batch();
    for (final cat in categories) {
      batch.insert('categories', cat);
    }
    await batch.commit(noResult: true);
  }

  // ── CATEGORY CRUD ──────────────────────────────────────────────

  Future<List<CategoryModel>> getCategories({String? type}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (type != null) {
      maps = await db.query(
        'categories',
        where: "type = ? OR type = 'both'",
        whereArgs: [type],
        orderBy: 'name ASC',
      );
    } else {
      maps = await db.query('categories', orderBy: 'name ASC');
    }

    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<int> insertCategory(CategoryModel cat) async {
    final db = await database;
    return await db.insert(
      'categories',
      cat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    // Will fail if transactions use this category (RESTRICT)
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ── TRANSACTION CRUD ───────────────────────────────────────────

  Future<void> insertTransaction(FinanceTransaction txn) async {
    final db = await database;
    await db.insert(
      'transactions',
      txn.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTransaction(FinanceTransaction txn) async {
    final db = await database;
    await db.update(
      'transactions',
      txn.toMap(),
      where: 'id = ?',
      whereArgs: [txn.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ── QUERIES ────────────────────────────────────────────────────

  // All transactions joined with category name
  Future<List<Map<String, dynamic>>> getAllTransactionsWithCategory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        t.id, t.type, t.amount, t.date, t.notes, t.created_at,
        c.name  AS category_name,
        c.icon  AS category_icon,
        c.color AS category_color
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      ORDER BY t.date DESC, t.created_at DESC
    ''');
  }

  // Filter by month  e.g. month='2024-04'
  Future<List<Map<String, dynamic>>> getTransactionsByMonth(
    String month,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT 
        t.id, t.type, t.amount, t.date, t.notes,
        c.name AS category_name, c.icon AS category_icon, c.color AS category_color
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE strftime('%Y-%m', t.date) = ?
      ORDER BY t.date DESC
    ''',
      [month],
    );
  }

  // Summary: total income, expense, balance
  Future<Map<String, double>> getSummary({String? month}) async {
    final db = await database;

    String whereClause = month != null
        ? "WHERE strftime('%Y-%m', date) = '$month'"
        : '';

    final income = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      $whereClause AND type = 'income'
    ''');

    final expense = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      $whereClause AND type = 'expense'
    ''');

    return {
      'income': (income.first['total'] as num).toDouble(),
      'expense': (expense.first['total'] as num).toDouble(),
    };
  }

  // Spending breakdown by category (for pie chart)
  Future<List<Map<String, dynamic>>> getCategoryBreakdown({
    required String type,
    String? month,
  }) async {
    final db = await database;
    final monthFilter = month != null
        ? "AND strftime('%Y-%m', t.date) = '$month'"
        : '';

    return await db.rawQuery(
      '''
      SELECT 
        c.name, c.color, c.icon,
        SUM(t.amount) AS total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = ? $monthFilter
      GROUP BY c.id
      ORDER BY total DESC
    ''',
      [type],
    );
  }

  // ── DATABASE MAINTENANCE ───────────────────────────────────────

  Future<void> deleteAllTransactions() async {
    final db = await database;
    await db.delete('transactions');
  }

  Future<void> closeDB() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
