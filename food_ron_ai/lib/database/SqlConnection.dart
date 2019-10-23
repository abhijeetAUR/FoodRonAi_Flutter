import 'dart:io';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {
  
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'ImageMeta';
  static final colFoodId = '_foodid';
  static final colFoodWeight = '_foodweight';
  static final colFoodName = '_foodname';
  static final colFoodCal = '_foodcal';
  static final colFoodFat = '_foodfat';
  static final colFoodSuger = '_foodsuger';
  static final colFoodPro = '_foodpro';
  static final colFoodCarb = 'foodcarb';
  static final colFoodServe = 'foodserve';
  static final colFoodFiber = 'foodfiber';
  static final success = 'success';
  

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }
  
  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $colFoodId TEXT PRIMARY KEY,
            $colFoodName TEXT NOT NULL,
            $colFoodWeight TEXT NOT NULL,
            $colFoodCal TEXT NOT NULL,
            $colFoodCarb TEXT NOT NULL,
            $colFoodFat TEXT NOT NULL,
            $colFoodFiber TEXT NOT NULL,
            $colFoodPro TEXT NOT NULL,
            $colFoodServe TEXT NOT NULL,
            $colFoodSuger TEXT NOT NULL,
            
          )
          ''');
  }
  
  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    for (var i = 1; i < Globals.apiitemCount; i++) {
        Map<String, dynamic> row = {
      DatabaseHelper.colFoodId : Globals.apiitems[i-1][i],
      DatabaseHelper.colFoodName : Globals.apiitems[i-1]['name'],
      DatabaseHelper.colFoodWeight : Globals.apiitems[i-1]['weight'],
      DatabaseHelper.colFoodCal : Globals.apiitems[i-1]['calorie'],
      DatabaseHelper.colFoodCarb : Globals.apiitems[i-1]['carbohydrates'],
      DatabaseHelper.colFoodFat : Globals.apiitems[i-1]['fat'],
      DatabaseHelper.colFoodFiber : Globals.apiitems[i-1]['fiber'],
      DatabaseHelper.colFoodPro : Globals.apiitems[i-1]['protein'],
      DatabaseHelper.colFoodServe : Globals.apiitems[i-1]['serve'],
      DatabaseHelper.colFoodSuger : Globals.apiitems[i-1]['sugar'],
    };
      await db.insert(table, row);  
    } 

    return 1;
  }

  // All of the rows are returned as a list of maps, where each map is 
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other 
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[colFoodName];
    return await db.update(table, row, where: '$colFoodName = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is 
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$colFoodName = ?', whereArgs: [id]);
  }
}