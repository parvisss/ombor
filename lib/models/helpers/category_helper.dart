import 'package:intl/intl.dart';
import 'package:ombor/models/category_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CategoryHelper {
  static CategoryHelper? _instance;
  static Database? _database;
  final String _tableName = 'categories';

  CategoryHelper._internatl();

  factory CategoryHelper() {
    return _instance ??= CategoryHelper._internatl();
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  //!create database
  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, '$_tableName.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate:
          (db, version) => db.execute('''
    CREATE TABLE $_tableName
    (
      id TEXT PRIMARY KEY,
      title TEXT,
      balance REAL,
      time TEXT,
      isArchived INTEGER DEFAULT 0
    );'''),
    );
  }

  //!create category
  Future insertCategory(CategoryModel category) async {
    final db = await database;
    try {
      await db.insert(
        _tableName,
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CategoryModel>> fetchCategories({
    required bool isArchive,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final db = await database;

      String query = 'SELECT * FROM $_tableName WHERE isArchived = ?';
      List<dynamic> args = [isArchive ? 1 : 0];

      // If fromDate is provided, filter by date
      if (fromDate != null) {
        query += ' AND time >= ?';
        args.add(fromDate.toIso8601String());
      }

      // If toDate is provided, filter by date
      if (toDate != null) {
        query += ' AND time <= ?';
        args.add(toDate.toIso8601String());
      }

      final maps = await db.rawQuery(query, args);

      if (maps.isEmpty) return [];

      return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
    } catch (e) {
      rethrow;
    }
  }

  //!update category
  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      _tableName,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  //!Delete category
  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  //! clear categories table
  Future<void> clearTable() async {
    final db = await database;
    await db.delete(_tableName);
  }

  //!change balance
  Future<void> changeBalance(String id, double amount, bool isIncrement) async {
    final db = await database;

    // Fetch the current balance
    var result = await db.query(
      _tableName,
      columns: ['balance'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      double currentBalance = result.first['balance'] as double;

      // Update the balance based on isIncrement flag
      double newBalance =
          isIncrement ? currentBalance + amount : currentBalance - amount;

      // Update the record with the new balance
      await db.update(
        _tableName,
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  //! Get total balance of all categories
  Future<double> getTotalBalance() async {
    final db = await database;
    try {
      // Faqat arxivlanmagan kategoriyalarni olish
      List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        columns: ['balance'],
        where: 'isArchived = ?',
        whereArgs: [0],
      );

      // Umumiy balansni hisoblash
      double totalBalance = maps.fold(0.0, (sum, item) {
        return sum + (item['balance'] as double);
      });

      return totalBalance;
    } catch (e) {
      return 0.0;
    }
  }

  //! Archive or unarchive category
  Future<void> archiveMultipleCategories(
    List<String> ids,
    int isArchived,
  ) async {
    final db = await database;

    Batch batch = db.batch();

    for (String id in ids) {
      batch.update(
        _tableName,
        {'isArchived': isArchived},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteLocalDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(
      dbPath,
      'categories.db',
    ); // database nomi bilan bir xil bo'lishi kerak
    await deleteDatabase(path);
    print('✅ Local database deleted: $path');
  }

  //!search
  Future<List<CategoryModel>> searchCategories(String query) async {
    final db = await database;
    return db
        .query(
          'categories',
          where: 'LOWER(title) LIKE ? OR CAST(balance AS TEXT) LIKE ?',
          whereArgs: ['%${query.toLowerCase()}%', '%$query%'],
        )
        .then((maps) => maps.map((e) => CategoryModel.fromMap(e)).toList());
  }

  //!filter by date
  Future<List<CategoryModel>> filterCategoriesByDate({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    String? fromFormatted =
        fromDate != null ? DateFormat('dd/MM/yyyy').format(fromDate) : null;
    String? toFormatted =
        toDate != null ? DateFormat('dd/MM/yyyy').format(toDate) : null;

    // Agar fromDate va toDate berilgan bo'lsa
    if (fromFormatted != null && toFormatted != null) {
      maps = await db.query(
        _tableName,
        where: 'time BETWEEN ? AND ?',
        whereArgs: [fromFormatted, toFormatted],
      );
    }
    // Agar faqat fromDate berilgan bo'lsa (fromDate'dan boshlab)
    else if (fromFormatted != null) {
      maps = await db.query(
        _tableName,
        where: 'time >= ?',
        whereArgs: [fromFormatted],
      );
    }
    // Agar faqat toDate berilgan bo'lsa (toDate'ga qadar)
    else if (toFormatted != null) {
      maps = await db.query(
        _tableName,
        where: 'time <= ?',
        whereArgs: [toFormatted],
      );
    }
    // Agar ikkala parametr ham null bo'lsa
    else {
      maps = await db.query(_tableName);
    }

    if (maps.isEmpty) return [];

    return List.generate(
      maps.length,
      (i) => CategoryModel.fromMap(maps[maps.length - 1 - i]), // reversed
    );
  }
}
