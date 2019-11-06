import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_ron_ai/CounterClass.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/bloc/HomeListBloc.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:food_ron_ai/ui/ImageDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      parseJsonInResponseObject(value, itemMetaId, itemId);
    });
  }

  void parseJsonInResponseObject(value, itemMetaId, itemId) {
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
    print(imageUploadResponse);
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
    } else {
      print('camera error');
    }
    _image = image;
  }

  @override
  void dispose() {
    // TODO: implement dispose
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

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //TODO: Pass fetched recoreds to bloc and render on ui
    //then on increment function update the values and update it in db
    getRecords();
  }

  getRecords() async {
    //TODO: Check if db is created first
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

  @override
  Widget build(BuildContext context) {
    if (imageList == null) {
      imageList = List<DataModelImageMeta>();
      updateListView();
    }

    return Scaffold(
      appBar: Globals.topAppBar,
      // body: FoodItems(),
      body: Stack(
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
                                color: Colors.black26,
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
                              child: Image.network(
                                // snapshot.data[index].img_url,// Change this
                                'https://dummyimage.com/600x400/000/fff',
                                fit: BoxFit.fill,
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
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: () {
                  getImage(true);
                },
                icon: Icon(Icons.camera),
                label: Text("${Globals.cameraTxt}"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future navigateTo(context, ImageUploadResponse response) async {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => ImageDetails(
                imageUploadResponse: response,
              )));
}

Future compressImage(File) async {
  Uint8List m = File.path.readAsBytesSync();
  ui.Image x = await decodeImageFromList(m);
  ByteData bytes = await x.toByteData();
  print('height is ${x.height}'); //height of original image
  print('width is ${x.width}'); //width of oroginal image

  print('array is $m');
  print('original image size is ${bytes.lengthInBytes}');

  ui
      .instantiateImageCodec(m, targetHeight: 2160, targetWidth: 2160)
      .then((codec) {
    codec.getNextFrame().then((frameInfo) async {
      ui.Image i = frameInfo.image;
      print('image width is ${i.width}'); //height of resized image
      print('image height is ${i.height}'); //width of resized image
      ByteData bytes = await i.toByteData();
      File.writeAsBytes(bytes.buffer.asUint32List());
      print('resized image size is ${bytes.lengthInBytes}');
      return i;
    });
  });
}
