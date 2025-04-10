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

time TEXT,

isArchived INTEGER DEFAULT 0

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

  Future<List<CashFlowModel>> getCashFlows(
    String tableName, {

    bool? isArchived,
  }) async {
    try {
      tableName = 'cash_flow_$tableName';

      final db = await database;

      await _createTableIfNotExists(tableName);

      List<Map<String, dynamic>> maps;

      if (isArchived != null) {
        maps = await db.query(
          tableName,

          where: 'isArchived = ?',

          whereArgs: [isArchived ? 1 : 0],
        );
      } else {
        maps = await db.query(tableName);
      }

      List<CashFlowModel> data =
          maps.map((e) => CashFlowModel.fromMap(e)).toList();

      return data.reversed.toList();
    } catch (e) {
      return [];
    }
  }

  // //! UPDATE

  // Future<int> updateCashFlow(String tableName, CashFlowModel cashFlow) async {

  // tableName = 'cash_flow_$tableName';

  // try {

  // final db = await database;

  // await _createTableIfNotExists(tableName);

  // return await db.update(

  // tableName,

  // cashFlow.toMap(),

  // where: 'id = ?',

  // whereArgs: [cashFlow.id],

  // );

  // } catch (e) {

  // rethrow;

  // }

  // }

  //! Bir nechta jadvalni o'chirish

  Future<void> deleteTables(List<String> tableNames) async {
    final db = await database;

    for (String tableName in tableNames) {
      tableName = 'cash_flow_$tableName';

      try {
        await db.execute('DROP TABLE IF EXISTS $tableName;');

        // ignore: empty_catches
      } catch (e) {}
    }
  }

  //! Barcha cash flowlarni barcha jadvallardan olish

  Future<List<CashFlowModel>> getAllCashFlowsFromAllTables({
    bool? isArchived,
  }) async {
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

        bool hasId = false;

        bool hasCategoryId = false;

        bool hasTitle = false;

        bool hasIsPositive = false;

        bool hasAmount = false;

        bool hasTime = false;

        bool hasIsArchivedColumn = false;

        for (var column in columns) {
          if (column['name'] == 'id') hasId = true;

          if (column['name'] == 'categoryId') hasCategoryId = true;

          if (column['name'] == 'title') hasTitle = true;

          if (column['name'] == 'isPositive') hasIsPositive = true;

          if (column['name'] == 'amount') hasAmount = true;

          if (column['name'] == 'time') hasTime = true;

          if (column['name'] == 'isArchived') hasIsArchivedColumn = true;
        }

        if (hasId &&
            hasCategoryId &&
            hasTitle &&
            hasIsPositive &&
            hasAmount &&
            hasTime) {
          List<Map<String, dynamic>> maps;

          if (isArchived != null && hasIsArchivedColumn) {
            maps = await db.query(
              tableName,

              where: 'isArchived = ?',

              whereArgs: [isArchived ? 1 : 0],
            );
          } else if (hasIsArchivedColumn) {
            maps = await db.query(
              tableName,

              where: 'isArchived = ?',

              whereArgs: [0], // Faqat arxivlanmaganlarni olish
            );
          } else {
            maps = await db.query(
              tableName,
            ); // isArchived ustuni yo'q bo'lsa, hammasini olamiz
          }

          allResults.addAll(maps.map((e) => CashFlowModel.fromMap(e)).toList());
        }
      }

      return allResults;
    } catch (e) {
      return [];
    }
  }

  //!search

  Future<List<CashFlowModel>> searchAllTables(
    String query, {

    bool? isArchived,
  }) async {
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

        bool hasIsArchivedColumn = false;

        for (var column in columns) {
          if (column['name'] == 'title') hasTitle = true;

          if (column['name'] == 'comment') hasComment = true;

          if (column['name'] == 'amount') hasAmount = true;

          if (column['name'] == 'isArchived') hasIsArchivedColumn = true;
        }

        if (hasTitle || hasComment || hasAmount) {
          List<Map<String, dynamic>> maps;

          List<String> whereClauses = [
            'LOWER(title) LIKE ?',

            'LOWER(comment) LIKE ?',

            'CAST(amount AS TEXT) LIKE ?',
          ];

          List<String> whereArgs = [
            '%${query.toLowerCase()}%',

            '%${query.toLowerCase()}%',

            '%$query%',
          ];

          if (isArchived != null && hasIsArchivedColumn) {
            whereClauses.add('isArchived = ?');

            whereArgs.add(isArchived ? '1' : '0');
          }

          maps = await db.query(
            tableName,

            where: whereClauses.join(' AND '),

            whereArgs: whereArgs,
          );

          allResults.addAll(maps.map((e) => CashFlowModel.fromMap(e)).toList());
        }
      }

      return allResults;
    } catch (e) {
      return [];
    }
  }

  //! Arxivlash/arxivdan chiqarish

  Future archiveCashFlow(String tableName, String id, int archive) async {
    tableName = 'cash_flow_$tableName';

    try {
      final db = await database;

      await _createTableIfNotExists(tableName);

      await db.update(tableName, {'isArchived': archive});
    } catch (e) {
      rethrow;
    }
  }
}
