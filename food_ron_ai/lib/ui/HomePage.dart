import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_ron_ai/CounterClass.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/bloc/HomeListBloc.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/ui/ImageDetails.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:food_ron_ai/database/DatabaseHelper.dart';
import 'package:food_ron_ai/database/DataModelImageMeta.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  final HomeListBloc _homeListBloc = HomeListBloc();
  File cimage;
  int counterForLengthCheck;
  int counterForLengthCheckOfSaveReponse = 0;
  int counterForLengthCheckOfSaveImageSuggestions = 0;
  int counterForLengthCheckOfSaveImageSuggestionsAndItem = 0;
  DataModelImageMeta dataModelImageMeta;
  ImageUploadResponse imageUploadResponse;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<DataModelImageMeta> imageList;
  int count = 0;
  final authorizationToken = "96331CA0-7959-402E-8016-B7ABB3287A16";
  bool _fetchingResponse = false;
  AnimationController _controller;
  static const List<IconData> icons = const [Icons.wallpaper, Icons.camera];
  static const List<String> iconlabels = const ["Gallery", "Camera"];
  DateTime selectedDate = DateTime.now();
  var dateSelected;

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
      setState(() {
        _fetchingResponse = false;
      });
      parseResponse(value, itemMetaId, itemId);
    });
  }

  void parseResponse(value, itemMetaId, itemId) async {
    Map<String, dynamic> mappingData = json.decode(value);
    if (mappingData != null && mappingData.isNotEmpty) {
      imageUploadResponse = ImageUploadResponse();
      imageUploadResponse.id = itemId;
      imageUploadResponse.itemMetaId = itemMetaId;
      imageUploadResponse.imgUrl = mappingData['img_url'];
      imageUploadResponse.infImgUrl = mappingData['inf_img_url'];
      imageUploadResponse.itemCount = mappingData['item_count'];

      Response resposne = await http.get(mappingData['img_url']);
      var base64Image = base64Encode(resposne.bodyBytes);
      Response resposneOfInfImage = await http.get(mappingData['inf_img_url']);
      var base64InfImage = base64Encode(resposneOfInfImage.bodyBytes);
      imageUploadResponse.base64InfImage = base64InfImage;
      imageUploadResponse.base64Image = base64Image;
      imageUploadResponse.datetime = selectedDate
          .toString()
          .substring(0, 10); //DateTime.now().toString().substring(0, 10);
      List<dynamic> items = mappingData['items'];
      for (var item in items) {
        item["itemMetaId"] = itemMetaId;
        item["datetime"] = selectedDate
            .toString()
            .substring(0, 10); //DateTime.now().toString().substring(0, 10);
        var value = ImageUploadMetaItems.fromJson(item);
        value.sugg.forEach((oneItem) {
          oneItem.itemMetaId = value.itemMetaId;
          oneItem.itemMetaSuggId = value.id;
        });
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
      //first check if response suggestion object is present,
      //if present then save to db
      if (imageUploadResponse
          .items[counterForLengthCheckOfSaveReponse].sugg.isNotEmpty) {
        // saveSuggestionsToDb();
        //Check there is some error while saving sugar
      }
      result = await databaseHelper.insertImageMetaData(
          imageUploadResponse.items[counterForLengthCheckOfSaveReponse]);

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

  saveSuggestionsToDb() {
    var result;
    result = databaseHelper.insertDataInSuggestionDb(imageUploadResponse
        .items[counterForLengthCheckOfSaveImageSuggestionsAndItem]
        .sugg[counterForLengthCheckOfSaveImageSuggestions]);
    if (counterForLengthCheckOfSaveImageSuggestions !=
        (imageUploadResponse
                .items[counterForLengthCheckOfSaveImageSuggestionsAndItem]
                .sugg
                .length -
            1)) {
      counterForLengthCheckOfSaveImageSuggestions += 1;
      // counterForLengthCheckOfSaveImageSuggestionsAndItem += 1;
      saveSuggestionsToDb();
    }
  }

  deleteImageAndMetaFromImageTable(
      AsyncSnapshot<List<ImageUploadResponse>> snapshot, int index) {
    final id = snapshot.data[index].id;
    final result = databaseHelper.deleteImageDataFromImageTable(id);

    snapshot.data.removeAt(index);
    _homeListBloc.updateHomeList(snapshot.data);
  }

  Future getImage(bool isCamera) async {
    File image;
    if (isCamera == true) {
      image = await ImagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxHeight: 1024,
          maxWidth: 1024);

      if (image != null && image.path != null) {
        image = await FlutterExifRotation.rotateImage(path: image.path);

        if (image != null) {
          setState(() {
            _fetchingResponse = true;
          });
          uploadImage(image);
        }
      }
    } else {
      image = await ImagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxHeight: 1024,
          maxWidth: 1024);
      if (image != null) {
        setState(() {
          _fetchingResponse = true;
        });
        uploadImage(image);
      }
    }
  }

  getTodaysRecordsFromDb() async {
    var result = await databaseHelper.getTodaysRecords();
    if (result != null) {
      sendDataToBlockForMetaData(result);
    }
  }

  getMetaRecordsFromDb(List<ImageUploadResponse> list) async {
    var result = await databaseHelper.getTodaysRecords();
    if (result != null) {
      sendDataToBlockForImageWithMetaData(result, list);
    }
  }

  getRecords() async {
    var result = await databaseHelper.getAllMetaDataListFilterByDate(
        selectedDate.toString().substring(0, 10));

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
    final todaysMetaDataList = lstImageUploadMetaItems
        .where((item) =>
            item.datetime.contains(selectedDate.toString().substring(0, 10)))
        .toList();
    _homeListBloc.sinkTodaysMeta(todaysMetaDataList);
  }

  List<ImageUploadResponse> getListOfImageUploadResponse(List<dynamic> result) {
    List<ImageUploadResponse> lstImageUploadResponse =
        List<ImageUploadResponse>();
    for (var item in result) {
      ImageUploadResponse imageUploadResponse = ImageUploadResponse();
      imageUploadResponse.id = item["id"];
      imageUploadResponse.imgUrl = item["img_url"];
      imageUploadResponse.infImgUrl = item["inf_img_url"];
      imageUploadResponse.itemMetaId = item["itemMetaId"];
      imageUploadResponse.datetime = item["datetime"];
      imageUploadResponse.base64Image = item["base64Image"].toString();
      imageUploadResponse.base64InfImage = item["base64InfImage"].toString();
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
          .toStringAsFixed(2);
    }
    return item != null ? "${item}g" : "0g";
  }

  getTotalFats(List<ImageUploadMetaItems> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.fat)
          .toList()
          .reduce((combine, next) => combine + next)
          .toStringAsFixed(2);
    }
    return item != null ? "${item}g" : "0g";
  }

  getTotalProtein(List<ImageUploadMetaItems> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.protein)
          .toList()
          .reduce((combine, next) => combine + next)
          .toStringAsFixed(2);
    }
    return item != null ? "${item}g" : "0g";
  }

  getTotalCalories(List<ImageUploadMetaItems> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.calorie)
          .toList()
          .reduce((combine, next) => combine + next)
          .toStringAsFixed(2);
    }
    return item != null ? item : "0";
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
    getAllRecordBySelectedDate(selectedDate.toString().substring(0, 10));
    getTodaysRecordsFromDb();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  getAllSuggestionRecords() async {
    var result = await databaseHelper.getAllSuggestionRecords();
  }

  getSelectedDateMetaRecordsFromDb() async {
    var result = await databaseHelper
        .getSelectedDateRecords(selectedDate.toString().substring(0, 10));
    if (result != null) {
      sendDataToBlockForMetaData(result);
    }
  }

  getAllRecordBySelectedDate(String selectedDate) async {
    var result =
        await databaseHelper.getAllMetaDataListFilterByDate(selectedDate);
    final list = getListOfImageUploadResponse(result);
    getMetaRecordsFromDb(list);
    getSelectedDateMetaRecordsFromDb();
  }

  @override
  Widget build(BuildContext context) {
    Future<Null> _selectDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2015, 8),
          lastDate: DateTime.now());
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
          dateSelected = picked.toString().substring(0, 10);

          getAllRecordBySelectedDate(dateSelected);
        });
    }

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
                child: FlatButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  child: Text(
                    '${selectedDate.toString().substring(0, 10)}',
                    style: TextStyle(
                        color: Color.fromRGBO(69, 150, 80, 1),
                        fontSize: 18,
                        fontFamily: 'HelveticaNeue',
                        fontWeight: FontWeight.w700),
                  ),
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
          padding: const EdgeInsets.all(5.0),
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
                            fontSize: 13,
                            color: Color.fromRGBO(189, 189, 221, 1),
                            fontFamily: 'HelveticaNeue',
                            fontWeight: FontWeight.w700))),
                Text(getTotalCarbohydrates(imageUploadResponseList),
                    style: TextStyle(
                        fontSize: 14,
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
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 2, bottom: 5),
                  child: Text("FAT",
                      style: TextStyle(
                          fontSize: 13,
                          color: Color.fromRGBO(189, 189, 221, 1),
                          fontFamily: 'HelveticaNeue',
                          fontWeight: FontWeight.w700))),
              Text(getTotalFats(imageUploadResponseList),
                  style: TextStyle(
                      fontSize: 14,
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
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 2, bottom: 5),
                  child: Text("KCAL",
                      style: TextStyle(
                          fontSize: 13,
                          color: Color.fromRGBO(189, 189, 221, 1),
                          fontFamily: 'HelveticaNeue',
                          fontWeight: FontWeight.w700))),
              Text(getTotalCalories(imageUploadResponseList),
                  style: TextStyle(
                      fontSize: 14,
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
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 2, bottom: 5),
                  child: Text("PROTEIN",
                      style: TextStyle(
                          fontSize: 13,
                          color: Color.fromRGBO(189, 189, 221, 1),
                          fontFamily: 'HelveticaNeue',
                          fontWeight: FontWeight.w700))),
              Text(getTotalProtein(imageUploadResponseList),
                  style: TextStyle(
                      fontSize: 14,
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
          child: Image.memory(base64Decode(snapshot.data[index].base64Image)),
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
            width: 9,
          ),
          Text(
            snapshot.data[index].items.isNotEmpty
                ? snapshot.data[index].items
                    .map((oneItem) => oneItem.calorie)
                    .toList()
                    .reduce((first, next) => first + next)
                    .toStringAsFixed(2)
                    .toString()
                : 0.toString(),
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
            snapshot.data[index].items.isNotEmpty
                ? snapshot.data[index].items
                    .map((oneItem) => oneItem.protein)
                    .toList()
                    .reduce((first, next) => first + next)
                    .toString()
                : 0.toString(),
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
            snapshot.data[index].items.isNotEmpty
                ? snapshot.data[index].items
                    .map((oneItem) => oneItem.carbohydrates)
                    .toList()
                    .reduce((first, next) => first + next)
                    .toString()
                : 0.toString(),
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
            snapshot.data[index].items.isNotEmpty
                ? snapshot.data[index].items
                    .map((oneItem) => oneItem.fat)
                    .toList()
                    .reduce((first, next) => first + next)
                    .toString()
                : 0.toString(),
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'HelveticaNeue',
                fontWeight: FontWeight.w700),
          )
        ],
      );
    }

    Widget rowForTodaysDateInMetaDetails(
        AsyncSnapshot<List<ImageUploadResponse>> snapshot, int index) {
      return Row(
        children: <Widget>[
          Text("Date",
              style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(189, 189, 221, 1),
                  fontFamily: 'HelveticaNeue',
                  fontWeight: FontWeight.w700)),
          SizedBox(
            width: 15,
          ),
          Text(
            snapshot.data[index].datetime,
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            rowForTodaysDateInMetaDetails(snapshot, index),
            // rowForCarbsInMetaDetails(snapshot, index),
            // rowForFatInMetaDetails(snapshot, index),
            // rowForProteinInMetaDetails(snapshot, index),
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
            final item = snapshot.data[index];
            return Dismissible(
              key: Key(item.id.toString()),
              onDismissed: (direction) {
                deleteImageAndMetaFromImageTable(snapshot, index);
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text("$index Row Deleted")));
              },
              // Show a red background as the item is swiped away.
              background: Container(
                color: Colors.redAccent,
                child: Center(
                  child: Text(
                    "Delete",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: (() {
                  navigateTo(context, snapshot.data[index]);
                }),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 0, child: cntForImage(snapshot, index)),
                      Expanded(
                          flex: 3,
                          child: rowForImageMetaDetails(snapshot, index)),
                      Expanded(flex: 1, child: cntForDisclosureIndicator())
                    ],
                  ),
                ),
              ),
            );
          });
    }

    Widget streamBuilderForImageAndMetaDetails() {
      return StreamBuilder<List<ImageUploadResponse>>(
        stream: _homeListBloc.imageListStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ImageUploadResponse>> snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            return lstForImageAndMetaDetails(snapshot);
          }
          return Container(
            child: Center(
              child: Text("Please click image to get started"),
            ),
          );
        },
      );
    }

    dialog() {
      showDialog(
          context: context,
          builder: (_) => NetworkGiffyDialog(
                image:
                    Image.asset('images/splashgraphic.png', fit: BoxFit.cover),
                title: Text('No Internet Connection',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
                description: Text(
                  'Please connect your device to internet',
                  textAlign: TextAlign.center,
                ),
                entryAnimation: EntryAnimation.DEFAULT,
                onlyOkButton: true,
                onOkButtonPressed: () {
                  Navigator.pop(context);
                },
              ));
    }

    Widget lstHolderForImageAndMetaDetails() {
      return Stack(
        children: <Widget>[
          streamBuilderForImageAndMetaDetails(),
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
            if (snapshot.hasData) {
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

    floatingSpeedDial() {
      return Padding(
        padding: EdgeInsets.only(bottom: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: new List.generate(icons.length, (int index) {
            Widget child = new Container(
              height: 70.0,
              //width: 56.0,
              alignment: FractionalOffset.topRight,
              child: new ScaleTransition(
                scale: new CurvedAnimation(
                  parent: _controller,
                  curve: new Interval(0.0, 1.0 - index / icons.length / 2.0,
                      curve: Curves.easeOut),
                ),
                child: new FloatingActionButton.extended(
                  heroTag: null,
                  backgroundColor: Colors.green,
                  label: Text("${iconlabels[index]}"),
                  icon: Icon(icons[index], color: Colors.white, size: 20),
                  onPressed: () async {
                    try {
                      final result =
                          await InternetAddress.lookup('www.google.com');
                      if (result.isNotEmpty &&
                          result[0].rawAddress.isNotEmpty) {
                        if (index == 0) {
                          getImage(false);
                          _controller.reverse();
                        } else {
                          getImage(true);
                          _controller.reverse();
                        }
                      }
                    } on SocketException catch (_) {
                      dialog();
                    }
                  },
                ),
              ),
            );
            return child;
          }).toList()
            ..add(
              FloatingActionButton(
                heroTag: null,
                child: new AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget child) {
                    return new Transform(
                      transform: new Matrix4.rotationZ(
                          _controller.value * 0.5 * math.pi),
                      alignment: FractionalOffset.center,
                      child: new Icon(
                        _controller.isDismissed ? Icons.add : Icons.close,
                        size: 30,
                      ),
                    );
                  },
                ),
                onPressed: () {
                  if (_controller.isDismissed) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                },
              ),
            ),
        ),
      );
    }

    Widget indicator() {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration:
            BoxDecoration(color: new Color.fromRGBO(241, 241, 241, 0.5)),
        child: Center(
          child: Container(
            height: (MediaQuery.of(context).size.width / 6).roundToDouble(),
            width: (MediaQuery.of(context).size.width / 6).roundToDouble(),
            color: Colors.green,
            child: SpinKitWave(
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
      );
    }

    Widget scaffoldBody() {
      return SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            title(),
            todayHealthMetaDataHolder(),
            Expanded(
              child: cardHolderForImageAndMetaDetails(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 249, 253, 1),
      body: Stack(
        children: <Widget>[
          scaffoldBody(),
          Center(
            child: _fetchingResponse ? indicator() : Container(),
          ),
        ],
      ),
      floatingActionButton: floatingSpeedDial(),
      //floatingActionButton: speedDial(),
    );
  }
}
