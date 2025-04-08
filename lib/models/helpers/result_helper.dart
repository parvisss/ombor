import 'package:ombor/models/cash_flow_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ResultHelper {
  static ResultHelper? _instance;
  static Database? _database;
  final String _tableName = 'cash_flow';

  ResultHelper._internal();

  factory ResultHelper() {
    return _instance ??= ResultHelper._internal();
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
      final dbPath = join(path, 'app_cash_flow_database.db');
      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            categoryId TEXT,
            title TEXT,
            comment TEXT,
            isPositive INTEGER,
            amount REAL,
            time TEXT
          );
        ''');
        },
      );
    } catch (e) {
      print("Error initializing database: $e");
      rethrow; // xatolikni yana tashlash
    }
  }

  //! INSERT(add)
  Future<void> insertCashFlow(CashFlowModel cashFlow) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        cashFlow.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  //! SELECT - Yil oralig‘i bo‘yicha filter qilish
  Future<List<CashFlowModel>> getCashFlows({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final db = await database;

      String query = 'SELECT * FROM $_tableName ';
      List<dynamic> args = [];
      List<String> conditions = [];

      //if from date is provided, filer by date
      if (fromDate != null) {
        conditions.add('time >= ?');
        args.add(fromDate.toIso8601String());
      }

      //if to date is provided, fikter by date
      if (toDate != null) {
        conditions.add('AND time <= ?');
        args.add(toDate.toIso8601String());
      }

      if (conditions.isNotEmpty) {
        query += ' WHERE ${conditions.join(' AND ')}';
      }

      final maps = await db.rawQuery(query, args);

      if (maps.isEmpty) return [];

      return List.generate(maps.length, (i) => CashFlowModel.fromMap(maps[i]));
    } catch (e) {
      print("Error fetching filtered cash flows: $e");
      return [];
    }
  }

  //! UPDATE
  Future<int> updateCashFlow(CashFlowModel cashFlow) async {
    try {
      final db = await database;
      return await db.update(
        _tableName,
        cashFlow.toMap(),
        where: 'id = ?',
        whereArgs: [cashFlow.id],
      );
    } catch (e) {
      print("Error updating cash flow: $e");
      rethrow;
    }
  }

  //! DELETE
  Future<int> deleteCashFlow(String id) async {
    try {
      final db = await database;
      return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("Error deleting cash flow: $e");
      rethrow;
    }
  }

  //! Tozalash
  Future<void> clearTable() async {
    try {
      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      print("Error clearing table: $e");
      rethrow;
    }
  }
}
