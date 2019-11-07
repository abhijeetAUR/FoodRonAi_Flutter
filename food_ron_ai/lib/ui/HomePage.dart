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
import 'package:sqflite/sqflite.dart';
import 'package:food_ron_ai/database/DatabaseHelper.dart';
import 'package:food_ron_ai/database/DataModelImageMeta.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  final HomeListBloc _homeListBloc = HomeListBloc();
  File _image;
  File cimage;
  int counterForLengthCheck;
  int counterForLengthCheckOfSaveReponse = 0;
  //file upload image funtion.
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
    imageUploadResponse = ImageUploadResponse();
    imageUploadResponse.id = itemId;
    imageUploadResponse.itemMetaId = itemMetaId;
    imageUploadResponse.img_url = mappingData['img_url'];
    imageUploadResponse.inf_img_url = mappingData['inf_img_url'];
    imageUploadResponse.item_count = mappingData['item_count'];
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

  void _save() async {
    int result;
    if (imageUploadResponse.id != null) {
      result = await databaseHelper.insertImageMeta(imageUploadResponse);
      if (result != null) {
        _saveMetaDataOfImage();
      }
    }
  }

  _saveMetaDataOfImage() async {
    int result;
    result = await databaseHelper.insertImageMetaData(
        imageUploadResponse.items[counterForLengthCheckOfSaveReponse]);
    print(result);
    if (counterForLengthCheckOfSaveReponse !=
        (imageUploadResponse.items.length - 1)) {
      counterForLengthCheckOfSaveReponse += 1;
      _saveMetaDataOfImage();
    } else {
      //TODO Update ui
      getRecords();
    }
  }

  Future getImage(bool isCamera) async {
    File image;
    if (isCamera) {
      image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 70);
      uploadImage(image);
    }
    _image = image;
  }

  @override
  void dispose() {
    _imageDataBloc.dispose();
    super.dispose();
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<DataModelImageMeta>> imageListFuture =
          databaseHelper.getImageList();
      imageListFuture.then((imageList) {
        setState(() {
          this.imageList = imageList;
          this.count = imageList.length;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getRecords();
  }

  getRecords() async {
    var result = await databaseHelper.getAllRecords("imagetable");
    print(result);
    if (result != null) {
      sendDataToBlock(result);
    }
  }

  Future sendDataToBlock(List<dynamic> result) async {
    List<ImageUploadResponse> lstImageUploadResponse =
        List<ImageUploadResponse>();
    for (var item in result) {
      ImageUploadResponse imageUploadResponse = ImageUploadResponse();
      imageUploadResponse.id = item["id"];
      imageUploadResponse.img_url = item["img_url"];
      imageUploadResponse.inf_img_url = item["inf_img_url"];
      imageUploadResponse.itemMetaId = item["itemMetaId"];
      lstImageUploadResponse.add(imageUploadResponse);
    }
    _homeListBloc.updateHomeList(lstImageUploadResponse);
  }

  Stack buildStreamBuilder() {
    return Stack(
      children: <Widget>[
        new StreamBuilder<List<ImageUploadResponse>>(
          stream: _homeListBloc.imageListStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<ImageUploadResponse>> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                padding: EdgeInsets.all(5),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Hero(
                      tag: snapshot.data[index].id,
                      child: Material(
                        child: InkWell(
                          onTap: () {
                            navigateTo(context, snapshot.data[index]);
                          },
                          child: GridTile(
                            footer: Container(
                              decoration: new BoxDecoration(
                                color: Colors.black26,
                                borderRadius:
                                    new BorderRadiusDirectional.circular(10),
                              ),
                              child: ListTile(
                                leading: Text(
                                  snapshot.data[index].id.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: new BorderRadius.circular(10),
                              child: Image.network(
                                snapshot.data[index].img_url, // Change this
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
        new Container(
          padding: EdgeInsets.all(15),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton.extended(
              onPressed: () {
                getImage(true);
              },
              icon: Icon(
                Icons.camera,
                color: Colors.white,
              ),
              label: Text(
                "${Globals.cameraTxt}",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageList == null) {
      imageList = List<DataModelImageMeta>();
      updateListView();
    }

    Widget dateChangeBtnContainer(){
      return Container(
        height: 80,
        color: Colors.redAccent,
              padding: EdgeInsets.all(15),
              child: Row(
              children: <Widget>[
                SizedBox.fromSize(
                  size: Size(45, 45), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange, // button color
                      child: InkWell(
                        splashColor: Colors.green, // splash color
                        onTap: () {}, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.arrow_back_ios), // icon// text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(child: Center(child: Text("Today",style: TextStyle(fontSize: 20),))),
                SizedBox.fromSize(
                  size: Size(45, 45), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange, // button color
                      child: InkWell(
                        splashColor: Colors.green, // splash color
                        onTap: () {}, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.arrow_forward_ios), // icon// text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              ],
                
              ),
            );

    }

    Widget multipleStatusValueWidget(){

      return Container(
        padding: EdgeInsets.only(top: 20),
        child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text("CARB"),
                Text("67g")
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text("FAT"),
                Text("67g")
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text("PROT"),
                Text("67g")
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text("KCAL"),
                Text("67g")
              ],
            ),
          ),
        ],
        ),
      );
    }

    Widget statusWidgetContainer() {
      return Container(
        height: 150,
        child: Column(
          children: <Widget>[
            dateChangeBtnContainer(),
            multipleStatusValueWidget()
            
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "foodron.ai",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Column(
        children: <Widget>[
          statusWidgetContainer(),
          Expanded(
            child: buildStreamBuilder(),
          )
        ],
      ),
    );
  }

Future navigateTo(context, ImageUploadResponse response) async {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => ImageDetails(
                imageUploadResponse: response,
              )));
}
}