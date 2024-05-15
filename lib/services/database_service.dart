import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

import '../models/data.dart';
import '../models/test_table.dart';

class DatabaseHelper {
  static const _databaseName = "my_database.db";
  static const _databaseVersion = 1;

  static const tableDevices = 'devices';
  static const deviceId = 'id';
  static const deviceName = 'name';
  static const deviceLastSynced = 'lastsynced';

  static const tableDataTypes = 'datatypes';
  static const dataTypeId = 'id';
  static const dataTypeName = 'name';
  static const dataTypeUnit = 'unit';

  static const tableTestTable = 'testtable';
  static const testTableId = 'id';
  static const testTableName = 'name';
  static const testTableDescription = 'desctiption';

  static const tableData = 'data';
  static const dataId = 'id';
  static const dataDeviceId = 'device_id';
  static const dataDataTypeId = 'datatype_id';
  static const dataValue = 'value';

  factory DatabaseHelper() {
    return instance;
  }

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableDevices (
        $deviceId INTEGER PRIMARY KEY,
        $deviceName TEXT NOT NULL,
        $deviceLastSynced DATETIME
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableDataTypes (
        $dataTypeId INTEGER PRIMARY KEY,
        $dataTypeName TEXT NOT NULL,
        $dataTypeUnit TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTestTable (
        $testTableId INTEGER PRIMARY KEY,
        $testTableName TEXT NOT NULL,
        $testTableDescription TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableData (
        $dataId INTEGER PRIMARY KEY,
        $dataDeviceId INTEGER NOT NULL,
        $dataDataTypeId INTEGER NOT NULL,
        $dataValue REAL,
        FOREIGN KEY ($dataDeviceId) REFERENCES $tableDevices ($deviceId) ON DELETE CASCADE,
        FOREIGN KEY ($dataDataTypeId) REFERENCES $tableDataTypes ($dataTypeId) ON DELETE CASCADE
      )
    ''');
  }

// Implement methods for CRUD operations here
  Future<int> insertData(int deviceId, int dataTypeId, double value) async {
    Database db = await instance.database;
    return await db.insert(tableData, {
      dataDeviceId: deviceId,
      dataDataTypeId: dataTypeId,
      dataValue: value,
    });
  }

  Future<void> insertMultipleData(List<Data> dataList) async {
    Database db = await instance.database;
    await db.transaction((txn) async {
      for (var data in dataList) {
        await txn.insert(tableData, data.toMap());
      }
    });
  }

  Future<int> insertTestData(int deviceId, String name, String description) async {
    Database db = await instance.database;
    return await db.insert(tableTestTable, {
      testTableId: deviceId,
      testTableName: name,
      testTableDescription: description,
    });
  }

  Future<List<TestTable>> getAllTestTables() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('testtable');

    return List.generate(maps.length, (i) {
      return TestTable.fromMap(maps[i]);
    });
  }

  Future<int?> getCount() async{
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(id) FROM testtable'));
  }

  Future<int?> getMax() async{
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT MAX(id) FROM testtable'));
  }
}
