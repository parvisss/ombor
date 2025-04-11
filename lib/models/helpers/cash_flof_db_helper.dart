import 'package:easy_localization/easy_localization.dart';
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
      rethrow;
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
              isArchived INTEGER DEFAULT 0,
              isInstallment INTEGER DEFAULT 0
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

  Future<List<CashFlowModel>> getCashFlows({
    required String tableName,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isIncomeIncluded,
    bool? isExpenceIncluded,
    bool? isInstallmentIncluded,
  }) async {
    try {
      tableName = 'cash_flow_$tableName';
      final db = await database;
      await _createTableIfNotExists(tableName);

      List<Map<String, dynamic>> maps;
      List<String> whereClauses = [];
      List<dynamic> whereArgs = [];

      // Sana bo‘yicha filter
      if (fromDate != null) {
        whereClauses.add('time >= ?');
        whereArgs.add(DateFormat('yyyy-MM-dd HH:mm:ss').format(fromDate));
      }

      if (toDate != null) {
        final endOfDay = toDate.add(
          const Duration(hours: 23, minutes: 59, seconds: 59),
        );
        whereClauses.add('time <= ?');
        whereArgs.add(DateFormat('yyyy-MM-dd HH:mm:ss').format(endOfDay));
      }

      // Tur bo‘yicha filterlarni yig‘ish
      List<String> typeConditions = [];

      if (isIncomeIncluded == true) {
        typeConditions.add('(isPositive = 1)');
      }
      if (isExpenceIncluded == true) {
        typeConditions.add('(isPositive = 0 AND isInstallment = 0)');
      }
      if (isInstallmentIncluded == true) {
        typeConditions.add('(isPositive = 0 AND isInstallment = 1)');
      }

      // Agar hech narsa tanlanmagan bo‘lsa — hech qanday type filter ishlatmaymiz
      if (typeConditions.isNotEmpty) {
        String combinedTypes = typeConditions.join(' OR ');
        whereClauses.add('($combinedTypes)');
      }

      String? whereClause;
      if (whereClauses.isNotEmpty) {
        whereClause = whereClauses.join(' AND ');
      }

      maps = await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
      );

      List<CashFlowModel> data =
          maps.map((e) => CashFlowModel.fromMap(e)).toList();

      return data.reversed.toList();
    } catch (e) {
      print("Error filtering cash flows: $e");
      return [];
    }
  }

  // //! UPDATE

  Future updateCashFlow(String tableName, CashFlowModel cashFlow) async {
    tableName = 'cash_flow_$tableName';

    try {
      final db = await database;

      await _createTableIfNotExists(tableName);
      await db.update(
        tableName,

        cashFlow.toMap(),

        where: 'id = ?',

        whereArgs: [cashFlow.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  //! Bir nechta jadvalni o'chirish

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

  //! Barcha cash flowlarni barcha jadvallardan, arxivlanganligiga qaramasdan olish
  Future<List<CashFlowModel>> getAllCashFlowsFromAllTablesUnfiltered() async {
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

        for (var column in columns) {
          if (column['name'] == 'id') hasId = true;
          if (column['name'] == 'categoryId') hasCategoryId = true;
          if (column['name'] == 'title') hasTitle = true;
          if (column['name'] == 'isPositive') hasIsPositive = true;
          if (column['name'] == 'amount') hasAmount = true;
          if (column['name'] == 'time') hasTime = true;
        }

        if (hasId &&
            hasCategoryId &&
            hasTitle &&
            hasIsPositive &&
            hasAmount &&
            hasTime) {
          final List<Map<String, dynamic>> maps = await db.query(tableName);
          allResults.addAll(maps.map((e) => CashFlowModel.fromMap(e)).toList());
        }
      }

      return allResults;
    } catch (e) {
      return [];
    }
  }

  //!search

  // Future<List<CashFlowModel>> searchAllTables(
  //   String query, {

  //   bool? isArchived,
  // }) async {
  //   try {
  //     final db = await database;

  //     final List<Map<String, dynamic>> tables = await db.rawQuery(
  //       "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'cash_flow_%';",
  //     );

  //     List<CashFlowModel> allResults = [];

  //     for (var table in tables) {
  //       final tableName = table['name'];

  //       final List<Map<String, dynamic>> columns = await db.rawQuery(
  //         "PRAGMA table_info($tableName);",
  //       );
  //       print(columns[tabl]);
  //       print('-------------');
  //       bool hasTitle = false;

  //       bool hasComment = false;

  //       bool hasAmount = false;

  //       for (var column in columns) {
  //         if (column['name'] == 'title') hasTitle = true;

  //         if (column['name'] == 'comment') hasComment = true;

  //         if (column['name'] == 'amount') hasAmount = true;
  //       }

  //       if (hasTitle || hasComment || hasAmount) {
  //         List<Map<String, dynamic>> maps;

  //         List<String> whereClauses = [
  //           'LOWER(title) LIKE ?',

  //           'LOWER(comment) LIKE ?',

  //           'CAST(amount AS TEXT) LIKE ?',
  //         ];

  //         List<String> whereArgs = [
  //           '%${query.toLowerCase()}%',

  //           '%${query.toLowerCase()}%',

  //           '%$query%',
  //         ];

  //         maps = await db.query(
  //           tableName,

  //           where: whereClauses.join(' AND '),

  //           whereArgs: whereArgs,
  //         );

  //         print(maps.length);
  //         allResults.addAll(maps.map((e) => CashFlowModel.fromMap(e)).toList());
  //       }
  //     }
  //     print(allResults.length);
  //     return allResults;
  //   } catch (e) {
  //     return [];
  //   }
  // }

  List<CashFlowModel> searchCashFlowsFromList({
    required List<CashFlowModel> cashFlows,
    required String query,
  }) {
    if (query.isEmpty) {
      return cashFlows; // Agar qidiruv so'zi bo'sh bo'lsa, barcha elementlarni qaytarish
    }

    final lowerQuery = query.toLowerCase();

    return cashFlows.where((flow) {
      final titleMatch = flow.title.toLowerCase().contains(lowerQuery);
      final commentMatch =
          flow.comment?.toLowerCase().contains(lowerQuery) ?? false;
      final amountMatch = flow.amount.toString().contains(query);

      return titleMatch || commentMatch || amountMatch;
    }).toList();
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

  //! Barcha jadvallardan isInstallment=1 bo'lgan cash flowlarni olish
  Future<List<CashFlowModel>> getAllInstallmentCashFlows() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'cash_flow_%';",
      );

      List<CashFlowModel> installmentResults = [];

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
        bool hasIsInstallmentColumn = false;

        for (var column in columns) {
          if (column['name'] == 'id') hasId = true;
          if (column['name'] == 'categoryId') hasCategoryId = true;
          if (column['name'] == 'title') hasTitle = true;
          if (column['name'] == 'isPositive') hasIsPositive = true;
          if (column['name'] == 'amount') hasAmount = true;
          if (column['name'] == 'time') hasTime = true;
          if (column['name'] == 'isInstallment') hasIsInstallmentColumn = true;
        }

        if (hasId &&
            hasCategoryId &&
            hasTitle &&
            hasIsPositive &&
            hasAmount &&
            hasTime &&
            hasIsInstallmentColumn) {
          final List<Map<String, dynamic>> maps = await db.query(
            tableName,
            where: 'isInstallment = ?',
            whereArgs: [1],
          );
          installmentResults.addAll(
            maps.map((e) => CashFlowModel.fromMap(e)).toList(),
          );
        }
      }

      return installmentResults;
    } catch (e) {
      print("Error getting all installment cash flows: $e");
      return [];
    }
  }

  //! Barcha installmentlarning umumiy narhini topish
  Future<double> getTotalInstallmentAmount() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'cash_flow_%';",
      );

      double totalInstallmentAmount = 0.0;

      for (var table in tables) {
        final tableName = table['name'];

        final List<Map<String, dynamic>> columns = await db.rawQuery(
          "PRAGMA table_info($tableName);",
        );

        bool hasIsInstallmentColumn = false;
        bool hasAmountColumn = false;

        for (var column in columns) {
          if (column['name'] == 'isInstallment') hasIsInstallmentColumn = true;
          if (column['name'] == 'amount') hasAmountColumn = true;
        }

        if (hasIsInstallmentColumn && hasAmountColumn) {
          final List<Map<String, dynamic>> maps = await db.query(
            tableName,
            columns: ['amount'],
            where: 'isInstallment = ?',
            whereArgs: [1],
          );

          for (var map in maps) {
            totalInstallmentAmount += (map['amount'] as num).toDouble();
          }
        }
      }

      return totalInstallmentAmount;
    } catch (e) {
      print("Error getting total installment amount: $e");
      return 0.0;
    }
  }

  //! Archive da bo'lmagan va installment bo'lgan cash flow'larning umumiy narhini topish
  Future<double> getTotalCashFlowAmount() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'cash_flow_%';",
      );

      double totalActiveInstallmentAmount = 0.0;

      for (var table in tables) {
        final tableName = table['name'];

        final List<Map<String, dynamic>> columns = await db.rawQuery(
          "PRAGMA table_info($tableName);",
        );

        bool hasIsInstallmentColumn = false;
        bool hasAmountColumn = false;
        bool hasIsArchivedColumn =
            false; // isArchived ustunini tekshirish uchun

        for (var column in columns) {
          if (column['name'] == 'isInstallment') hasIsInstallmentColumn = true;
          if (column['name'] == 'amount') hasAmountColumn = true;
          if (column['name'] == 'isArchived') hasIsArchivedColumn = true;
        }

        if (hasIsInstallmentColumn && hasAmountColumn) {
          if (hasIsArchivedColumn) {
            final List<Map<String, dynamic>> maps = await db.query(
              tableName,
              columns: ['amount'],
              where: 'isInstallment = ? AND isArchived = ?',
              whereArgs: [
                0,
                0,
              ], // isInstallment = 1 (installment) va isArchived = 0 (faol)
            );

            for (var map in maps) {
              totalActiveInstallmentAmount += (map['amount'] as num).toDouble();
            }
          } else {
            // Agar jadvalda isArchived ustuni bo'lmasa, barcha installmentlarni qo'shamiz (oldingi mantiq)
            final List<Map<String, dynamic>> maps = await db.query(
              tableName,
              columns: ['amount'],
              where: 'isInstallment = ?',
              whereArgs: [1],
            );

            for (var map in maps) {
              totalActiveInstallmentAmount += (map['amount'] as num).toDouble();
            }
          }
        }
      }

      return totalActiveInstallmentAmount;
    } catch (e) {
      print("Error getting total active installment amount: $e");
      return 0.0;
    }
  }

  Future<double> getCategoryCashFlowAmount({required String categoryId}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'cash_flow_%';",
      );

      double totalActiveInstallmentAmount = 0.0;

      for (var table in tables) {
        final tableName = table['name'];

        final List<Map<String, dynamic>> columns = await db.rawQuery(
          "PRAGMA table_info($tableName);",
        );

        bool hasAmountColumn = false;
        bool hasIsArchivedColumn =
            false; // isArchived ustunini tekshirish uchun
        bool hasCategoryIdColumn = false;
        for (var column in columns) {
          if (column['name'] == 'amount') hasAmountColumn = true;
          if (column['name'] == 'isArchived') hasIsArchivedColumn = true;
          if (column['name'] == 'categoryId') hasCategoryIdColumn = true;
        }

        if (hasAmountColumn && hasCategoryIdColumn) {
          if (hasIsArchivedColumn) {
            final List<Map<String, dynamic>> maps = await db.query(
              tableName,
              columns: ['amount'],
              where: 'isInstallment = ? AND isArchived = ? AND categoryId = ?',
              whereArgs: [
                0,
                0,
                categoryId,
              ], // isInstallment = 1 (installment) va isArchived = 0 (faol)
            );

            for (var map in maps) {
              totalActiveInstallmentAmount += (map['amount'] as num).toDouble();
            }
          } else {
            // Agar jadvalda isArchived ustuni bo'lmasa, barcha installmentlarni qo'shamiz (oldingi mantiq)
            final List<Map<String, dynamic>> maps = await db.query(
              tableName,
              columns: ['amount'],
              where: 'isInstallment = ?',
              whereArgs: [1],
            );

            for (var map in maps) {
              totalActiveInstallmentAmount += (map['amount'] as num).toDouble();
            }
          }
        }
      }

      return totalActiveInstallmentAmount;
    } catch (e) {
      print("Error getting total active installment amount: $e");
      return 0.0;
    }
  }

  Future<void> deleteTablesByIds(List<String> idsToDelete) async {
    final db = await database;
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'cash_flow_%';",
    );

    for (var table in tables) {
      final tableName = table['name'];

      for (String idToDelete in idsToDelete) {
        await db.delete(tableName, where: 'id = ?', whereArgs: [idToDelete]);
      }
    }
  }
}
