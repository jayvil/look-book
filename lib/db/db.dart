import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:my_lookbook/db/models.dart';
import 'package:my_lookbook/db/sql_statements.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// TODO: change prints to logging

abstract class DB {
  static Database? _db;
  static int get _version => 1;
  static Future<void> init() async {
    if (_db != null) {
      print('DB already initialized');
      return;
    }
    try {
      // Avoid errors caused by flutter upgrade.
      // Importing 'package:flutter/widgets.dart' is required.
      WidgetsFlutterBinding.ensureInitialized();
      String path = await getDatabasesPath();
      print('Initializing Database at $path');
      _db = await openDatabase(
        join(path, 'data.db'),
        version: _version,
        onCreate: onCreate,
      );
      print('DB initialized');
    } catch (ex) {
      print(ex);
    }
  }

  static void onCreate(Database db, int version) async {
    // TODO: onCreate should be all or nothing. Do error handling
    print('Creating database...');
    // Create and populate clothing_types table
    print('Creating clothing types table');
    await db.execute(kSqlCreateClothingTypesTable);
    await db.execute(kSqlPopulateClothingTypesTable);
    print('Clothing types table created');

    // Create and populate clothing_sub_types table
    print('Creating clothing sub types table');
    await db.execute(kSqlCreateSubTypesTable);
    await db.execute(kSqlPopulateClothingSubTypesTable);
    print('Clothing sub types table created');

    // Create clothing item table
    await db.execute(kSqlCreateClothingItemTable);
    print('clothing item table created');

    // Create the wardrobe table
    await db.execute(kSqlCreateWardrobeTable);
    print('Wardrobe table created');
    db.query('clothing_sub_types');

    // Create the colors table
    await db.execute(kSqlCreateColorsTable);
    await db.execute(kSqlPopulateColorsTable);
    print('colors table created');

    // Create the patterns table
    await db.execute(kSqlCreatePatternsTable);
    await db.execute(kSqlPopulatePatternsTable);
    print('patterns table created');

    // Create the materials table
    await db.execute(kSqlCreateMaterialsTable);
    await db.execute(kSqlPopulateMaterialsTable);
    print('materials table created');

    // Create the brands table
    await db.execute(kSqlCreateBrandsTable);
    await db.execute(kSqlPopulateBrandsTable);
    print('brands table created');

    print('Database created');
  }

  static Future<List<Map<String, dynamic>>> queryAll(String table) async =>
      _db!.query(table);

  // static Future<List<Map<String, DatabaseTable>>> queryAll(String table) async {
  //   List<Map<String, DatabaseTable>> retList = [];
  //   List<Map<String, dynamic>> data = await _db!.query(table);
  //   for(Map<String, dynamic> mapData in data){
  //     mapData.entries.forEach((entry) {
  //       print('Key = ${entry.key} : Value = ${entry.value}');
  //       retList.add({entry.key:entry.value as DatabaseTable});
  //     });
  //   }
  //   return retList;
  // }

  static Future<List<Map<String, dynamic>>> query(
    String table,
    List<String> columns,
    String where,
    List<String> whereArgs,
  ) async =>
      _db!.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
      );

  static Future<List<Map<String, dynamic>>> rawQuery(String sql) async =>
      await _db!.rawQuery(sql);

  static Future<int> rawInsert(String sql) async => await _db!.rawInsert(sql);

  static Future<int> insert(String table, DatabaseTable model) async =>
      await _db!.insert(
        table,
        model.toMap(),
        // conflictAlgorithm: ConflictAlgorithm.replace,
      );

  static Future<int> update(String table, DatabaseTable model) async =>
      await _db!.update(
        table,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );

  static Future<int> delete(String table, DatabaseTable model) async =>
      await _db!.delete(
        table,
        where: 'id = ?',
        whereArgs: [model.id],
      );
}
//
// class DatabaseHandler {
//   static Future<Database>? db;
//
//   DatabaseHandler() {
//     db = getDatabase();
//   }
//
//   Future<Database> getDatabase() async {
//     print('Getting database...');
//     // Avoid errors caused by flutter upgrade.
//     // Importing 'package:flutter/widgets.dart' is required.
//     WidgetsFlutterBinding.ensureInitialized();
//     final database = openDatabase(
//       // Set the path to the database. Note: Using the `join` function from the
//       // `path` package is best practice to ensure the path is correctly
//       // constructed for each platform
//       join(
//         await getDatabasesPath(),
//         'data.db',
//       ),
//       // When the database is first created, create a table to store data.
//       onCreate: (Database db, int version) {
//         print('No existing database. Creating database...');
//         // Run the CREATE TABLE statement on the database.
//         db.execute(kSqlCreateClothingTypesTable);
//         db.execute(kSqlPopulateClothingTypesTable);
//       },
//       // Set the version. This executes the onCreate function and provides a
//       // path to perform database upgrades and downgrades.
//       version: 1,
//     );
//     return database;
//   }
//
//   Future<bool> insert(DatabaseTable model, String tableName) async {
//     // Get a reference to the database
//     final database = await db!;
//     int id = -1;
//     id = await database.insert(
//       tableName,
//       model.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//     if (id != -1) {
//       print('Inserted $id into table $tableName');
//       return true;
//     } else {
//       print('Unable to insert into $tableName');
//       return false;
//     }
//   }

// Future<List<Page>> search(String word, int parentId) async {
//   if (!initialized) await this._initialize();
//   String query = '''
//     SELECT * FROM users
//     LIMIT 25''';
//   return await this.db.rawQuery(query);
// }

// }
