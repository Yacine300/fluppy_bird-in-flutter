import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DBHelper {
  static Future<void> insertNewRecord(int record) async {
    final dbPath = await sql.getDatabasesPath();
    final sqlDB = await sql.openDatabase(
      path.join(dbPath, 'fluppy_bird_.db'),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS score (
          id TEXT PRIMARY KEY,
          score INT
        )
      ''');
      },
      version: 1,
    );

    final currentRecord = await getCurrentRecord(sqlDB);

    if (currentRecord == null || record > currentRecord) {
      await sqlDB.transaction((txn) async {
        await txn.insert('score', {"score": record},
            conflictAlgorithm: sql.ConflictAlgorithm.replace);
      });
    }
  }

  static Future<int?> getCurrentRecord(sql.Database sqlDB) async {
    final List<Map<String, dynamic>> records = await sqlDB.query('score');

    if (records.isNotEmpty) {
      final int currentRecord = records.last['score'] as int;
      return currentRecord;
    } else {
      return 0;
    }
  }

// Fetch the record from the database
  static Future<int?> getRecord() async {
    final dbPath = await sql.getDatabasesPath();
    final sqlDB = await sql.openDatabase(
      path.join(dbPath, 'fluppy_bird_.db'),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS score (
          id INTEGER PRIMARY KEY,
          score INTEGER
        )
      ''');
      },
      version: 1,
    );

    // Query the 'score' table and fetch the record value
    final List<Map<String, dynamic>> records = await sqlDB.query('score');

    // Check if there's a record in the table
    if (records.isNotEmpty) {
      // Assuming 'score' column is an integer, you can extract it like this
      final int recordValue = records.last['score'] as int;
      return recordValue;
    } else {
      // If there are no records in the table, return null
      return 0;
    }
  }
}
