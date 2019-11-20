import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/model_class/SearchItemModelClass.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:food_ron_ai/database/DataModelImageMeta.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // singlton DatabaseHelper
  static Database _database;

  String imageTable = 'imagetable';
  String imageTableMetaData = 'imagetableMetaData';
  String additionalMetaData = 'additionalMetaData';
  String suggestionMetaData = 'suggestionMetaData';

  String colMetaId = 'id';
  String colItemMetaId = 'itemMetaId';
  String colName = 'name';
  String colServe = 'serve';
  String colWeight = 'weight';
  String colCalorie = 'calorie';
  String colCarbohydrates = 'carbohydrates';
  String colFiber = 'fiber';
  String colFat = 'fat';
  String colProtein = 'protein';
  String colSugar = 'sugar';
  String colMetaDatetime = 'datetime';
  String colBase64Image = "base64Image";
  String colBase64InfImage = "base64InfImage";
  String colBBox = "bbox";
  String colSuggestions = "sugg";
  String colDatetime = "datetime";
  String colId = 'id';
  String colImgUrl = 'img_url';
  String colInfImgUrl = 'inf_img_url';
  String colItemMetaSuggId = 'itemMetaSuggId';
  //For Additional items
  String colServeSize = 'serveSize';
  String colServeUnit = 'serveUnit';

  List<String> colItemClass;
  List<ImgItemDataMapper> colItems;
  String itemMeta = "itemMeta";

  DatabaseHelper._createInstance(); // named constructorr to create instance of database helper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // exectued only once singleton object
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
    var imageDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return imageDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    Batch batch = db.batch();
    batch.execute(''' CREATE TABLE $imageTable
      (
        $colId INTEGER PRIMARY KEY,
        $colImgUrl TEXT,
        $colInfImgUrl TEXT,
        $itemMeta TEXT,
        $colItemMetaId INTEGER,
        $colDatetime TEXT,
        $colBase64Image TEXT,
        $colBase64InfImage TEXT
      )''');
    batch.execute(''' CREATE TABLE $imageTableMetaData
      (
        $colMetaId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colItemMetaId INTEGER, 
        $colName TEXT,
        $colServe REAL,
        $colWeight REAL,
        $colCalorie REAL,
        $colCarbohydrates REAL,
        $colFiber REAL,
        $colFat REAL,
        $colProtein REAL,
        $colSugar REAL,
        $colMetaDatetime TEXT,
        $colBase64Image TEXT,
        $colBase64InfImage TEXT,        
        $colBBox BLOB,
        $colSuggestions BLOB
      )''');

    batch.execute(''' CREATE TABLE $additionalMetaData
      (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colItemMetaId INTEGER,
        $colName TEXT,
        $colServeSize REAL,
        $colServeUnit REAL,
        $colWeight REAL,
        $colCalorie REAL,
        $colCarbohydrates REAL,
        $colFiber REAL,
        $colFat REAL,
        $colProtein REAL,
        $colSugar REAL
      )''');

    batch.execute(''' CREATE TABLE $suggestionMetaData
      (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colItemMetaId INTEGER,
        $colItemMetaSuggId INTEGER,
        $colName TEXT,
        $colServe REAL,
        $colServeSize REAL,
        $colServeUnit REAL,
        $colWeight REAL,
        $colCalorie REAL,
        $colCarbohydrates REAL,
        $colFiber REAL,
        $colFat REAL,
        $colProtein REAL,
        $colSugar REAL,
        $colDatetime TEXT
      )''');

    await batch.commit();
  }

  Future<int> insertDataInSuggestionDb(ImageUploadMetaSugg data) async {
    Database db = await this.database;
    var result = await db.insert(suggestionMetaData, data.toMap());
    return result;
  }

  Future<int> deleteMetaFromImageMetaTable(int id) async {
    Database db = await this.database;
    var result =
        db.delete(imageTableMetaData, where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<int> deleteImageDataFromImageTable(int id) async {
    Database db = await this.database;
    var result = db.delete(imageTable, where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<int> insertImageMeta(ImageUploadResponse dataModelImageMeta) async {
    Database db = await this.database;
    var result = await db.insert(imageTable, dataModelImageMeta.toMap());
    return result;
  }

  Future<int> insertItemInAdditionalMetaData(
      SerchedItemMetaData dataModelImageMeta) async {
    Database db = await this.database;
    var result =
        await db.insert(additionalMetaData, dataModelImageMeta.toMap());
    return result;
  }

  Future<List> getTodaysRecords() async {
    Database db = await this.database;
    var result = await db.rawQuery("SELECT * FROM $imageTableMetaData");
    return result.toList();
  }

  Future<int> insertImageMetaData(
      ImageUploadMetaItems dataModelImageMeta) async {
    Database db = await this.database;
    var result =
        await db.insert(imageTableMetaData, dataModelImageMeta.toMap());
    return result;
  }

  Future<List> getAllRecords() async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery("SELECT * FROM $imageTable");
    return result.toList();
  }

  Future<List> getAllSuggestionRecords() async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery("SELECT * FROM $suggestionMetaData");
    return result.toList();
  }

  Future<List> getAllAdditionalRecords() async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery("SELECT * FROM $additionalMetaData");
    return result.toList();
  }

  Future<List> getAllMetaDataList() async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery("SELECT * FROM $imageTableMetaData");
    return result.toList();
  }

  Future<List> getAllMetaRecords(int id) async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        "SELECT * FROM $imageTableMetaData WHERE $colItemMetaId = $id");
    return result.toList();
  }

  // Update Operation: Update a imagemeta object and save it to database
  Future<int> updateImage(ImageMetaData dataModelImageMeta) async {
    var db = await this.database;
    var result = await db.update(imageTableMetaData, dataModelImageMeta.toMap(),
        where: '$colId = ?', whereArgs: [dataModelImageMeta.id]);
    return result;
  }
}
