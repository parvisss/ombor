import 'package:ombor/models/cash_flow_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CashFlowDBHelper {
  static CashFlowDBHelper? _instance;
  static Database? _database;

  CashFlowDBHelper._internal();

  factory CashFlowDBHelper() {
    return _instance ??= CashFlowDBHelper._internal();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  //! Bazani yaratish
  Future<Database> _initDatabase() async {
    try {
      final path = await getDatabasesPath();
      final dbPath = join(path, 'app_database.db');
      return await openDatabase(dbPath, version: 1);
    } catch (e) {
      rethrow; // xatolikni yana tashlash
    }
  }

  //! Jadval bor yoki yo'qligini tekshiradi, bo'lmasa yaratadi
  Future<void> _createTableIfNotExists(String tableName) async {
    try {
      final db = await database;
      final exists =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT count(*) FROM sqlite_master WHERE type='table' AND name=?",
              [tableName],
            ),
          )! >
          0;

      if (!exists) {
        await db.execute('''
            CREATE TABLE $tableName (
              id TEXT PRIMARY KEY,
              categoryId TEXT,
              title TEXT,
              comment TEXT,
              isPositive INTEGER,
              amount REAL,
              time TEXT
            );
          ''');
      }
    } catch (e) {
      rethrow;
    }
  }

  //! INSERT
  Future<void> insertCashFlow(String tableName, CashFlowModel cashFlow) async {
    try {
      final db = await database;
      await _createTableIfNotExists(tableName);
      await db.insert(tableName, cashFlow.toMap());
    } catch (e) {
      rethrow;
    }
  }

  //! SELECT
  Future<List<CashFlowModel>> getCashFlows(String tableName) async {
    try {
      final db = await database;
      await _createTableIfNotExists(tableName);
      final List<Map<String, dynamic>> maps = await db.query(tableName);
      // Ro'yxatni teskari qilish
      List<CashFlowModel> data =
          maps.map((e) => CashFlowModel.fromMap(e)).toList();
      return data.reversed.toList(); // Teskari tartibda qaytarish
    } catch (e) {
      return [];
    }
  }

  //! UPDATE
  Future<int> updateCashFlow(String tableName, CashFlowModel cashFlow) async {
    try {
      final db = await database;
      await _createTableIfNotExists(tableName);
      return await db.update(
        tableName,
        cashFlow.toMap(),
        where: 'id = ?',
        whereArgs: [cashFlow.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  //! DELETE
  Future<int> deleteCashFlow(String id) async {
    try {
      final db = await database;
      await _createTableIfNotExists(id);
      return await db.delete('cash_flow', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  //! Ixtiyoriy jadvalni tozalash
  Future<void> clearTable(String tableName) async {
    try {
      final db = await database;
      await _createTableIfNotExists(tableName);
      await db.delete(tableName);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CashFlowModel>> searchAllTables(String query) async {
    try {
      final db = await database;

      // Barcha jadval nomlarini olish (sqLite'da buni qilish uchun sqlite_master jadvalidan foydalanamiz)
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table';",
      );

      List<CashFlowModel> allResults = [];

      // Har bir jadval uchun qidiruvni amalga oshiramiz
      for (var table in tables) {
        final tableName = table['name'];

        // Jadvalda kerakli ustunlar borligini tekshiramiz (title, comment, amount)
        final List<Map<String, dynamic>> columns = await db.rawQuery(
          "PRAGMA table_info($tableName);",
        );

        // Ustunlar mavjudligini tekshiramiz
        bool hasTitle = false;
        bool hasComment = false;
        bool hasAmount = false;

        for (var column in columns) {
          if (column['name'] == 'title') hasTitle = true;
          if (column['name'] == 'comment') hasComment = true;
          if (column['name'] == 'amount') hasAmount = true;
        }

        // Agar ustunlardan biri bo'lmasa, qidiruvni o'tkazmaymiz
        if (hasTitle || hasComment || hasAmount) {
          // Qidiruv so'rovi (title, comment, amount bo'yicha)
          final List<Map<String, dynamic>> maps = await db.query(
            tableName,
            where:
                'LOWER(title) LIKE ? OR LOWER(comment) LIKE ? OR CAST(amount AS TEXT) LIKE ?',
            whereArgs: [
              '%${query.toLowerCase()}%', // title uchun
              '%${query.toLowerCase()}%', // comment uchun
              '%$query%', // amount uchun
            ],
          );

          // Olingan natijalarni ro'yxatga qo'shamiz
          allResults.addAll(maps.map((e) => CashFlowModel.fromMap(e)).toList());
        }
      }

      return allResults; // Barcha jadvaldan olingan natijalar
    } catch (e) {
      return [];
    }
  }
}
