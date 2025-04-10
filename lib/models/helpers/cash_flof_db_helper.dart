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
      tableName = 'cash_flow_$tableName';
      final db = await database;
      await _createTableIfNotExists(tableName);
      await db.insert(tableName, cashFlow.toMap());
    } catch (e) {
      rethrow;
    }
  }

  //! SELECT (bitta jadvaldan)
  Future<List<CashFlowModel>> getCashFlows(String tableName) async {
    try {
      tableName = 'cash_flow_$tableName';

      final db = await database;
      await _createTableIfNotExists(tableName);
      final List<Map<String, dynamic>> maps = await db.query(tableName);
      List<CashFlowModel> data =
          maps.map((e) => CashFlowModel.fromMap(e)).toList();
      return data.reversed.toList();
    } catch (e) {
      return [];
    }
  }

  //! Barcha cash flowlarni berilgan category IDlar ro'yxati bo'yicha olish
  Future<List<CashFlowModel>> getAllCashFlowsByCategories(
    List<String> categoryIds,
  ) async {
    final db = await database;
    List<CashFlowModel> allCashFlows = [];

    for (final categoryId in categoryIds) {
      final tableName =
          'cash_flow_$categoryId'; // Har bir kategoriya uchun alohida jadval nomi

      // Jadval mavjudligini tekshiramiz
      final exists =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT count(*) FROM sqlite_master WHERE type='table' AND name=?",
              [tableName],
            ),
          )! >
          0;

      if (exists) {
        try {
          final List<Map<String, dynamic>> maps = await db.query(tableName);
          allCashFlows.addAll(
            maps.map((e) => CashFlowModel.fromMap(e)).toList(),
          );
        } catch (e) {
          print("Error getting cash flows from table $tableName: $e");
          // Jadvaldan ma'lumot olishda xatolik yuz bersa ham,
          // boshqa jadvallardan ma'lumot olishga harakat qilish uchun davom etamiz.
        }
      }
    }

    // Barcha jadvallardan olingan ma'lumotlarni teskari tartibda qaytarish
    return allCashFlows.reversed.toList();
  }

  // //! UPDATE
  // Future<int> updateCashFlow(String tableName, CashFlowModel cashFlow) async {
  //   try {
  //     final db = await database;
  //     await _createTableIfNotExists(tableName);
  //     return await db.update(
  //       tableName,
  //       cashFlow.toMap(),
  //       where: 'id = ?',
  //       whereArgs: [cashFlow.id],
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  //! DELETE (bitta jadvaldagi bitta yozuvni o'chirish uchun)
  Future<int> deleteCashFlow(String tableName, String id) async {
    tableName = 'cash_flow_$tableName';
    try {
      final db = await database;
      await _createTableIfNotExists(tableName);
      return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  //! Bir nechta jadvalni o'chirish
  Future<void> deleteTables(List<String> tableNames) async {
    final db = await database;
    for (String tableName in tableNames) {
      tableName = 'cash_flow_$tableName';

      try {
        await db.execute('DROP TABLE IF EXISTS $tableName;');
      } catch (e) {
        print("Error dropping table $tableName: $e");
      }
    }
  }

  //! Barcha cash flowlarni barcha jadvallardan olish
  Future<List<CashFlowModel>> getAllCashFlowsFromAllTables() async {
    try {
      final db = await database;

      // 'cash_flow_' bilan boshlanuvchi barcha jadvallarni olish
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'cash_flow_%';",
      );

      List<CashFlowModel> allResults = [];

      for (var table in tables) {
        final tableName = table['name'];

        // Jadvalda kerakli ustunlar borligini tekshiramiz (title, comment, amount - optional)
        final List<Map<String, dynamic>> columns = await db.rawQuery(
          "PRAGMA table_info($tableName);",
        );

        bool hasId = false;
        bool hasCategoryId = false;
        bool hasTitle = false;
        // ignore: unused_local_variable
        bool hasComment = false;
        bool hasIsPositive = false;
        bool hasAmount = false;
        bool hasTime = false;

        for (var column in columns) {
          if (column['name'] == 'id') hasId = true;
          if (column['name'] == 'categoryId') hasCategoryId = true;
          if (column['name'] == 'title') hasTitle = true;
          if (column['name'] == 'comment') hasComment = true;
          if (column['name'] == 'isPositive') hasIsPositive = true;
          if (column['name'] == 'amount') hasAmount = true;
          if (column['name'] == 'time') hasTime = true;
        }

        // Agar asosiy ustunlar mavjud bo'lsa, ma'lumotlarni olamiz
        if (hasId &&
            hasCategoryId &&
            hasTitle &&
            hasIsPositive &&
            hasAmount &&
            hasTime) {
          final List<Map<String, dynamic>> maps = await db.query(tableName);
          allResults.addAll(maps.map((e) => CashFlowModel.fromMap(e)).toList());
        } else {
          print(
            "Warning: Table $tableName does not have all required columns for CashFlowModel.",
          );
        }
      }

      return allResults;
    } catch (e) {
      print("Error getting all cash flows from all tables: $e");
      return [];
    }
  }

  // //! Ixtiyoriy jadvalni tozalash (barcha yozuvlarni o'chirish)
  // Future<void> clearTable(String tableName) async {
  //   try {
  //     final db = await database;
  //     await _createTableIfNotExists(tableName);
  //     await db.delete(tableName);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  //!search
  Future<List<CashFlowModel>> searchAllTables(String query) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'cash_flow_%';",
      );

      List<CashFlowModel> allResults = [];

      for (var table in tables) {
        final tableName = table['name'];

        final List<Map<String, dynamic>> columns = await db.rawQuery(
          "PRAGMA table_info($tableName);",
        );

        bool hasTitle = false;
        bool hasComment = false;
        bool hasAmount = false;

        for (var column in columns) {
          if (column['name'] == 'title') hasTitle = true;
          if (column['name'] == 'comment') hasComment = true;
          if (column['name'] == 'amount') hasAmount = true;
        }

        if (hasTitle || hasComment || hasAmount) {
          final List<Map<String, dynamic>> maps = await db.query(
            tableName,
            where:
                'LOWER(title) LIKE ? OR LOWER(comment) LIKE ? OR CAST(amount AS TEXT) LIKE ?',
            whereArgs: [
              '%${query.toLowerCase()}%',
              '%${query.toLowerCase()}%',
              '%$query%',
            ],
          );
          allResults.addAll(maps.map((e) => CashFlowModel.fromMap(e)).toList());
        }
      }

      return allResults;
    } catch (e) {
      return [];
    }
  }
}
