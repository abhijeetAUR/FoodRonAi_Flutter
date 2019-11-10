import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:food_ron_ai/CounterClass.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/bloc/HomeListBloc.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/ui/ImageDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:food_ron_ai/database/DatabaseHelper.dart';
import 'package:food_ron_ai/database/DataModelImageMeta.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  final HomeListBloc _homeListBloc = HomeListBloc();
  File cimage;
  int counterForLengthCheck;
  int counterForLengthCheckOfSaveReponse = 0;
  DataModelImageMeta dataModelImageMeta;
  ImageUploadResponse imageUploadResponse;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<DataModelImageMeta> imageList;
  int count = 0;
  final authorizationToken = "96331CA0-7959-402E-8016-B7ABB3287A16";

  uploadImage(File imageFile) async {
    var returnCounterValue = ReturnCounterValue();
    final itemId = await returnCounterValue.incrementCounterWithOne();
    final itemMetaId = await returnCounterValue.incrementCounterFromThousand();
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(Globals.imguploadurl);
    Map<String, String> headers = {"authorization": authorizationToken};
    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    request.files.add(multipartFile);

    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      parseResponse(value, itemMetaId, itemId);
    });
  }

  void parseResponse(value, itemMetaId, itemId) {
    Map<String, dynamic> mappingData = json.decode(value);
    if (mappingData != null && mappingData.isNotEmpty) {
      imageUploadResponse = ImageUploadResponse();
      imageUploadResponse.id = itemId;
      imageUploadResponse.itemMetaId = itemMetaId;
      imageUploadResponse.img_url = mappingData['img_url'];
      imageUploadResponse.inf_img_url = mappingData['inf_img_url'];
      imageUploadResponse.item_count = mappingData['item_count'];
      imageUploadResponse.datetime = DateTime.now().toString().substring(0, 10);
      List<dynamic> items = mappingData['items'];
      for (var item in items) {
        item["itemMetaId"] = itemMetaId;
        var value = ImageUploadMetaItems.fromJson(item);
        imageUploadResponse.items.add(value);
      }
      if (imageUploadResponse.items.length > 0) {
        counterForLengthCheck = imageUploadResponse.items.length;
      }
      _save();
    }
  }

  void _save() async {
    int result;
    if (imageUploadResponse.id != null) {
      result = await databaseHelper.insertImageMeta(imageUploadResponse);
      if (result != null) {
        counterForLengthCheckOfSaveReponse = 0;
        _saveMetaDataOfImage();
      }
    }
  }

  _saveMetaDataOfImage() async {
    int result;
    if (imageUploadResponse.items.isNotEmpty) {
      result = await databaseHelper.insertImageMetaData(
          imageUploadResponse.items[counterForLengthCheckOfSaveReponse]);
      print(result);
      if (counterForLengthCheckOfSaveReponse !=
          (imageUploadResponse.items.length - 1)) {
        counterForLengthCheckOfSaveReponse += 1;
        _saveMetaDataOfImage();
      } else {
        getRecords();
        getTodaysRecordsFromDb();
      }
    }
  }

  Future getImage(bool isCamera) async {
    File image;
    if (isCamera) {
      image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 70);
      if (image != null) {
        uploadImage(image);
      }
    }
  }

  getTodaysRecordsFromDb() async {
    var result = await databaseHelper
        .getTodaysRecords(DateTime.now().toString().substring(0, 10));
    if (result != null) {
      sendDataToBlockForMetaData(result);
    }
  }

  getMetaRecordsFromDb(List<ImageUploadResponse> list) async {
    var result = await databaseHelper
        .getTodaysRecords(DateTime.now().toString().substring(0, 10));
    if (result != null) {
      sendDataToBlockForImageWithMetaData(result, list);
    }
  }

  getRecords() async {
    var result = await databaseHelper.getAllRecords("imagetable");
    print(result);
    if (result != null) {
      final list = getListOfImageUploadResponse(result);
      getMetaRecordsFromDb(list);
    }
  }

  sendDataToBlockForImageWithMetaData(
      List result, List<ImageUploadResponse> list) {
    var lstImageUploadMetaItems = List<ImageUploadMetaItems>();
    for (var item in result) {
      var imageUploadMetaItems = ImageUploadMetaItems.fromJson(item);
      lstImageUploadMetaItems.add(imageUploadMetaItems);
    }

    for (var item in list) {
      var result = lstImageUploadMetaItems
          .where((oneItem) => oneItem.itemMetaId == item.itemMetaId)
          .toList();
      item.items.addAll(result);
    }
    _homeListBloc.updateHomeList(list);
  }

  sendDataToBlockForMetaData(List result) {
    var lstImageUploadMetaItems = List<ImageUploadMetaItems>();
    for (var item in result) {
      var imageUploadMetaItems = ImageUploadMetaItems.fromJson(item);
      lstImageUploadMetaItems.add(imageUploadMetaItems);
    }
    _homeListBloc.sinkTodaysMeta(lstImageUploadMetaItems);
  }

  List<ImageUploadResponse> getListOfImageUploadResponse(List<dynamic> result) {
    List<ImageUploadResponse> lstImageUploadResponse =
        List<ImageUploadResponse>();
    for (var item in result) {
      ImageUploadResponse imageUploadResponse = ImageUploadResponse();
      imageUploadResponse.id = item["id"];
      imageUploadResponse.img_url = item["img_url"];
      imageUploadResponse.inf_img_url = item["inf_img_url"];
      imageUploadResponse.itemMetaId = item["itemMetaId"];
      imageUploadResponse.datetime = item["datetime"];
      lstImageUploadResponse.add(imageUploadResponse);
    }
    return lstImageUploadResponse;
  }

  getTotalCarbohydrates(List<ImageUploadMetaItems> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.carbohydrates)
          .toList()
          .reduce((combine, next) => combine + next)
          .toString();
    }
    return item.isNotEmpty ? "$item g" : "0g";
  }

  getTotalFats(List<ImageUploadMetaItems> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.fat)
          .toList()
          .reduce((combine, next) => combine + next)
          .toString();
    }
    return item.isNotEmpty ? "$item g" : "0g";
  }

  getTotalProtein(List<ImageUploadMetaItems> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.protein)
          .toList()
          .reduce((combine, next) => combine + next)
          .toString();
    }
    return item.isNotEmpty ? "$item g" : "0g";
  }

  getTotalCalories(List<ImageUploadMetaItems> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.calorie)
          .toList()
          .reduce((combine, next) => combine + next)
          .toString();
    }
    return item.isNotEmpty ? item : "0";
  }

  void navigateTo(context, ImageUploadResponse response) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ImageDetails(
          imageUploadResponse: response,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imageDataBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getRecords();
    getTodaysRecordsFromDb();
  }

  @override
  Widget build(BuildContext context) {
    Widget dateChangeBtnContainer() {
      return Container(
        height: 50,
        padding: EdgeInsets.all(1),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  "Today",
                  style: TextStyle(
                      color: Color.fromRGBO(189, 189, 221, 1),
                      fontSize: 18,
                      fontFamily: 'HelveticaNeue',
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget cardForCarbohydrates(
        List<ImageUploadMetaItems> imageUploadResponseList) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 2, bottom: 5),
                    child: Text("CARB",
                        style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(189, 189, 221, 1),
                            fontFamily: 'HelveticaNeue',
                            fontWeight: FontWeight.w700))),
                Text(getTotalCarbohydrates(imageUploadResponseList),
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'HelveticaNeue',
                        fontWeight: FontWeight.w700))
              ],
            ),
          ),
        ),
      );
    }

    Widget cardForFat(List<ImageUploadMetaItems> imageUploadResponseList) {
      return Card(
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 2, bottom: 5),
                  child: Text("FAT",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(189, 189, 221, 1),
                          fontFamily: 'HelveticaNeue',
                          fontWeight: FontWeight.w700))),
              Text(getTotalFats(imageUploadResponseList),
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'HelveticaNeue',
                      fontWeight: FontWeight.w700))
            ],
          ),
        ),
      );
    }

    Widget cardForKCAL(List<ImageUploadMetaItems> imageUploadResponseList) {
      return Card(
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 2, bottom: 5),
                  child: Text("KCAL",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(189, 189, 221, 1),
                          fontFamily: 'HelveticaNeue',
                          fontWeight: FontWeight.w700))),
              Text(getTotalCalories(imageUploadResponseList),
                  style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(69, 150, 80, 1),
                      fontFamily: 'HelveticaNeue',
                      fontWeight: FontWeight.w700))
            ],
          ),
        ),
      );
    }

    Widget cardForProtein(List<ImageUploadMetaItems> imageUploadResponseList) {
      return Card(
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 2, bottom: 5),
                  child: Text("PROTEIN",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(189, 189, 221, 1),
                          fontFamily: 'HelveticaNeue',
                          fontWeight: FontWeight.w700))),
              Text(getTotalProtein(imageUploadResponseList),
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'HelveticaNeue',
                      fontWeight: FontWeight.w700))
            ],
          ),
        ),
      );
    }

    Widget metaDataHolder(List<ImageUploadMetaItems> imageUploadResponseList) {
      return Container(
        // padding: EdgeInsets.only(top: 10),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 1, child: cardForCarbohydrates(imageUploadResponseList)),
            Expanded(flex: 1, child: cardForFat(imageUploadResponseList)),
            Expanded(flex: 1, child: cardForProtein(imageUploadResponseList)),
            Expanded(flex: 1, child: cardForKCAL(imageUploadResponseList)),
          ],
        ),
      );
    }

    Widget cntForImage(
        AsyncSnapshot<List<ImageUploadResponse>> snapshot, index) {
      return Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Container(
          height: 70,
          width: 70,
          child: Image.network(
            snapshot.data[index].img_url, // Change this
            fit: BoxFit.fill,
          ),
        ),
      );
    }

    Widget rowForKCALInMetaDetails(
        AsyncSnapshot<List<ImageUploadResponse>> snapshot, int index) {
      return Row(
        children: <Widget>[
          Text("KCAL",
              style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(189, 189, 221, 1),
                  fontFamily: 'HelveticaNeue',
                  fontWeight: FontWeight.w700)),
          SizedBox(
            width: 21,
          ),
          Text(
            snapshot.data[index].items
                .map((oneItem) => oneItem.calorie)
                .toList()
                .reduce((first, next) => first + next)
                .toString(),
            style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(69, 150, 80, 1),
                fontFamily: 'HelveticaNeue',
                fontWeight: FontWeight.w700),
          )
        ],
      );
    }

    Widget rowForProteinInMetaDetails(
        AsyncSnapshot<List<ImageUploadResponse>> snapshot, int index) {
      return Row(
        children: <Widget>[
          Text("Protein",
              style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(189, 189, 221, 1),
                  fontFamily: 'HelveticaNeue',
                  fontWeight: FontWeight.w700)),
          SizedBox(
            width: 15,
          ),
          Text(
            snapshot.data[index].items
                .map((oneItem) => oneItem.protein)
                .toList()
                .reduce((first, next) => first + next)
                .toString(),
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'HelveticaNeue',
                fontWeight: FontWeight.w700),
          )
        ],
      );
    }

    Widget rowForCarbsInMetaDetails(
        AsyncSnapshot<List<ImageUploadResponse>> snapshot, int index) {
      return Row(
        children: <Widget>[
          Text("Carbs",
              style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(189, 189, 221, 1),
                  fontFamily: 'HelveticaNeue',
                  fontWeight: FontWeight.w700)),
          SizedBox(
            width: 20,
          ),
          Text(
            snapshot.data[index].items
                .map((oneItem) => oneItem.carbohydrates)
                .toList()
                .reduce((first, next) => first + next)
                .toString(),
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'HelveticaNeue',
                fontWeight: FontWeight.w700),
          )
        ],
      );
    }

    Widget rowForFatInMetaDetails(
        AsyncSnapshot<List<ImageUploadResponse>> snapshot, int index) {
      return Row(
        children: <Widget>[
          Text("Fat",
              style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(189, 189, 221, 1),
                  fontFamily: 'HelveticaNeue',
                  fontWeight: FontWeight.w700)),
          SizedBox(
            width: 40,
          ),
          Text(
            snapshot.data[index].items
                .map((oneItem) => oneItem.fat)
                .toList()
                .reduce((first, next) => first + next)
                .toString(),
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'HelveticaNeue',
                fontWeight: FontWeight.w700),
          )
        ],
      );
    }

    Widget rowForImageMetaDetails(
        AsyncSnapshot<List<ImageUploadResponse>> snapshot, int index) {
      return Padding(
        padding: const EdgeInsets.only(left: 20, right: 0, top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            rowForCarbsInMetaDetails(snapshot, index),
            rowForFatInMetaDetails(snapshot, index),
            rowForProteinInMetaDetails(snapshot, index),
            rowForKCALInMetaDetails(snapshot, index),
          ],
        ),
      );
    }

    Widget cntForDisclosureIndicator() {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Container(
          alignment: Alignment.centerRight,
          child: Icon(Icons.arrow_right),
        ),
      );
    }

    Widget lstForImageAndMetaDetails(
        AsyncSnapshot<List<ImageUploadResponse>> snapshot) {
      return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: (() {
                navigateTo(context, snapshot.data[index]);
              }),
              child: Row(
                children: <Widget>[
                  Expanded(flex: 1, child: cntForImage(snapshot, index)),
                  Expanded(
                      flex: 1, child: rowForImageMetaDetails(snapshot, index)),
                  Expanded(child: cntForDisclosureIndicator())
                ],
              ),
            );
          });
    }

    Widget streamBuilderForImageAndMetaDetails() {
      return StreamBuilder<List<ImageUploadResponse>>(
        stream: _homeListBloc.imageListStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ImageUploadResponse>> snapshot) {
          if (!snapshot.hasData && snapshot.data.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          return lstForImageAndMetaDetails(snapshot);
        },
      );
    }

    Widget cntFabCamera() {
      return Container(
        padding: EdgeInsets.all(15),
        child: Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            backgroundColor: Color.fromRGBO(69, 150, 80, 1),
            splashColor: Colors.green,
            child: FlatButton(
              child: Icon(
                Icons.camera,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () {
                getImage(true);
              },
            ),
            onPressed: () {},
          ),
        ),
      );
    }

    Widget lstHolderForImageAndMetaDetails() {
      return Stack(
        children: <Widget>[
          streamBuilderForImageAndMetaDetails(),
          cntFabCamera()
        ],
      );
    }

    Widget cardHolderForImageAndMetaDetails() {
      return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 24),
          child: lstHolderForImageAndMetaDetails());
    }

    Widget statusWidgetContainer(
        List<ImageUploadMetaItems> imageUploadResponseList) {
      return Container(
        margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 20),
        child: Column(
          children: <Widget>[
            dateChangeBtnContainer(),
            metaDataHolder(imageUploadResponseList)
          ],
        ),
      );
    }

    Widget todayMetaDataStreamBuilder() {
      return StreamBuilder<List<ImageUploadMetaItems>>(
          stream: _homeListBloc.todaysMetaStream,
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.hasData) {
              return statusWidgetContainer(snapshot.data);
            } else {
              return Container(
                child: Text(""),
              );
            }
          });
    }

    Widget todayHealthMetaDataHolder() {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: todayMetaDataStreamBuilder(),
        ),
      );
    }

    Widget title() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "HOME",
            style: TextStyle(
                color: Color.fromRGBO(45, 46, 51, 1),
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    Widget scaffoldBody() {
      return SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            title(),
            SizedBox(height: 10),
            todayHealthMetaDataHolder(),
            Expanded(
              child: cardHolderForImageAndMetaDetails(),
            )
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 249, 253, 1),
      body: scaffoldBody(),
    );
  }
}
