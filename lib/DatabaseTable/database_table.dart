import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart' as mobile;
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart' as ffi;


class DatabaseTable {
  /*Singleton object - means create one object from the entitre class using internal constructor . 
  beginning with _ means private to that library._internal() is a private constructor.*/
  static final DatabaseTable instance = DatabaseTable._internal();
  DatabaseTable._internal();

  /*? → Initially nullable. _database → Private variable.*/
  static mobile.Database? _database;

  /*Database access . If the Database is already have , it can be reusable or can be initialize.
  Check already have database, 'yes' means returning the existing database or move next step.
  */

  Future<Database> get database async {
    if (_database != null) {
      print("loading the old db");
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }
  /*Init Database. mobile.database is the datatype for mobile SQLite package
  Using 2 packages - mobile, windows.
  import 'package:sqflite/sqflite.dart' as mobile;
  import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
  */

  Future<mobile.Database> _initDatabase() async {

  /* Windows database.It can execute current platform and windows platform are same.
  In windows, normal SQFlite implementation can't be used.
  So initialize the FFI(Foreign Function Interface) implementation. 
  so it configure the datafactory for windows*/

  if (defaultTargetPlatform == TargetPlatform.windows) {

    mobile.sqfliteFfiInit();

    ffi.databaseFactory = ffi.databaseFactoryFfi;

    final dbFolder = Directory(r'D:\Database Creation');

    if (!await dbFolder.exists()) {
      await dbFolder.create(recursive: true);
    }

    final dbPath = join(dbFolder.path, 'billbox.db');

    print("Windows Database Path: $dbPath");

    return await ffi.databaseFactory.openDatabase(
      dbPath,
      options: mobile.OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute("PRAGMA foreign_keys = ON");
        },
        onCreate: _createTables,
      ),
    );
  }

  // Android mobile database.Download packages in terminal flutter pub add sqflite  . it helps to run the app in android
  else {

    final dbFolder = await mobile.getDatabasesPath();

    final dbPath = join(dbFolder, 'billbox.db');

    print("Mobile Database Path: $dbPath");

    return await mobile.openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: _createTables,
    );
  }
}

  //create all tables
  Future<void> _createTables(mobile.Database db, int version) async {
    // 1. Items Menu Table
    await db.execute('''
      CREATE TABLE Items_Menu (

        Item_Menu_Id INTEGER PRIMARY KEY AUTOINCREMENT,

        Item_Name TEXT NOT NULL unique,

        Price NUMERIC NOT NULL,

        GST_Perc NUMERIC(4,2)Null,

        HSN INTEGER Null  ,

        Is_Active INTEGER NOT NULL DEFAULT 1

      )
    ''');

    // 2. Mode of Bill Table
    await db.execute('''
      CREATE TABLE Mode_of_Bill (

        Bill_Mode_Id INTEGER PRIMARY KEY AUTOINCREMENT,

        Bill_Mode_Name TEXT NOT NULL unique,

        Bill_Prefix TEXT NOT NULL,
        Is_Active Integer not null default 1

      )
    ''');

    // 3. Bill Header Table
    await db.execute('''
      CREATE TABLE Bill_Header (

        Bill_Id INTEGER PRIMARY KEY AUTOINCREMENT,

        Bill_No TEXT NOT NULL UNIQUE,

        Customer_Name TEXT null,

        Contact_No TEXT null,

        Total_Amount NUMERIC(10,2) NOT NULL,

        Bill_Date TEXT  NOT NULL,

        Bill_Mode_Id INTEGER NOT NULL,

        FOREIGN KEY (Bill_Mode_Id)
        REFERENCES Mode_of_Bill(Bill_Mode_Id)

      )
    ''');

    // 4. Bill Details Table
    await db.execute('''
      CREATE TABLE Bill_Details (

        Bill_Detail_Id INTEGER PRIMARY KEY AUTOINCREMENT,

        Bill_Id INTEGER NOT NULL,

        Item_Menu_Id INTEGER NOT NULL,

        Quantity INTEGER NOT NULL,

        Price NUMERIC(10,2) NOT NULL,

        GST_Perc NUMERIC(4,2)null,

        Tax_Amount NUMERIC(10,2) null,

        Line_Total NUMERIC(10,2) NOT NULL,

        FOREIGN KEY (Bill_Id)
        REFERENCES Bill_Header(Bill_Id),

        FOREIGN KEY (Item_Menu_Id)       
         REFERENCES Items_Menu(Item_Menu_Id)

      )
    ''');
  }

  // Get all Items_Menu records
  Future<List<Map<String, dynamic>>> getItemsMenu() async {
    final db = await database;

    final records = await db.query('Items_Menu');

    return records;
  }

  /*Get Today's Total Bills and Total Amount.COALESCE() - Purpose of coalesce , the sum result is having null means it stores 0
   . rawQuery is used to select the data*/

  Future<Map<String, dynamic>> getTodayDashboardSummary() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT
        COUNT(Bill_Id) AS TotalBills,
        COALESCE(SUM(Total_Amount), 0) AS TotalAmount

      FROM Bill_Header

      WHERE date(Bill_Date) = date('now', 'localtime')
    ''');

    return result.first;
  }
  //Get Payment Summary

  Future<List<Map<String, dynamic>>> getTodayPaymentSummary() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT
      M.Bill_Mode_Name AS PaymentMode,

      COUNT(H.Bill_Id) AS BillCount,

      COALESCE(SUM(H.Total_Amount), 0) AS TotalAmount

    FROM Bill_Header H

    INNER JOIN Mode_of_Bill M
    ON H.Bill_Mode_Id = M.Bill_Mode_Id

    WHERE date(H.Bill_Date) = date('now', 'localtime')

    GROUP BY M.Bill_Mode_Id, M.Bill_Mode_Name

  ''');

    return result;
  }
}
