import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:food_ron_ai/database/DataModelImageMeta.dart';

class DatabaseHelper{

  static DatabaseHelper _databaseHelper; // singlton DatabaseHelper
  static Database _database;

  String imageTable = 'imagetable';
  String colId = 'id';
  String colIndexno = 'indexno';
  String colfoodname = 'foodname';
  String colweight = 'weight';
  String colcal = 'cal';
  String colcarb = 'carb';
  String colfat = 'fat';
  String colfiber = 'fiber';
  String colprotin = 'protin';
  String colserve = 'fiber';
  String colsuger = 'suger';
  String colimgurl = 'imgurl';
  


  DatabaseHelper._createInstance(); // named constructorr to create instance of database helper

  factory DatabaseHelper(){
    
    if(_databaseHelper ==  null){
        _databaseHelper = DatabaseHelper._createInstance();// exectued only once singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
	}

  Future<Database> initializeDatabase() async {
		// Get the directory path for both Android and iOS to store database.
		Directory directory = await getApplicationDocumentsDirectory();
		String path = directory.path + 'images.db';

		// Open/create the database at a given path
		var imageDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
		return imageDatabase;
	}

  void _createDb(Database db, int newVersion) async {

		await db.execute('CREATE TABLE $imageTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colIndexno TEXT, $colfoodname TEXT, $colweight TEXT, $colcal TEXT, $colcarb TEXT, $colfat TEXT, $colfiber TEXT, $colprotin TEXT, $colserve TEXT, $colsuger TEXT, $colimgurl TEXT )');
	}

  // Fetch Operation: Get all imagemeta objects from database
  Future<List<Map<String, dynamic>>> getImageMapList() async {
		Database db = await this.database;

		var result = await db.rawQuery('SELECT * FROM $imageTable ');
		//var result = await db.query('imageTable');
		return result;
	}

  // Insert Operation: Insert a datamodelimagemeta object to database
	Future<int> insertImage(DataModelImageMeta dataModelImageMeta) async {
		Database db = await this.database;
		var result = await db.insert(imageTable, dataModelImageMeta.toMap());
		return result;
	}

  // Update Operation: Update a imagemeta object and save it to database
	Future<int> updateImage(DataModelImageMeta dataModelImageMeta) async {
		var db = await this.database;
		var result = await db.update(imageTable, dataModelImageMeta.toMap(), where: '$colId = ?', whereArgs: [dataModelImageMeta.id]);
		return result;
	}

  // Delete Operation: Delete a imagemeta object from database
	Future<int> deleteImage(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $imageTable WHERE $colId = $id');
		return result;
	}

  // Get number of Note objects in database
	Future<int> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $imageTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
	Future<List<DataModelImageMeta>> getImageList() async {

		var imageMapList = await getImageMapList(); // Get 'Map List' from database
		int count = imageMapList.length;         // Count the number of map entries in db table

		List<DataModelImageMeta> noteList = List<DataModelImageMeta>();
		// For loop to create a 'Note List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			noteList.add(DataModelImageMeta.fromMapObject(imageMapList[i]));
		}

		return noteList;
	}
}
