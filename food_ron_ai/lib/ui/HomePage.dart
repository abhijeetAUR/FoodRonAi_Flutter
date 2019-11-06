import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
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
  //file upload image funtion.
  DataModelImageMeta dataModelImageMeta;
  ImageUploadResponse imageUploadResponse;

  uploadImage(File imageFile) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(Globals.imguploadurl);
    Map<String, String> headers = {
      "authorization": "96331CA0-7959-402E-8016-B7ABB3287A16"
    };
    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));
    request.files.add(multipartFile);

    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      Map<String, dynamic> mappingData = json.decode(value);
      imageUploadResponse = ImageUploadResponse();
      imageUploadResponse.id = 2;
      imageUploadResponse.img_url = mappingData['img_url'];
      imageUploadResponse.inf_img_url = mappingData['inf_img_url'];
      imageUploadResponse.item_count = mappingData['item_count'];
      List<dynamic> items = mappingData['items'];
      for (var item in items) {
        var value = ImageUploadMetaItems.fromJson(item);
        imageUploadResponse.items.add(value);
      }
      convertToString(imageUploadResponse);
      print(imageUploadResponse);
      _save();
      // Globals.apiResponse = json.decode(value);
      // processJsonResponse();
      // updateBlocList(Globals.apiitems, Globals.apiImgUrl);
      // dataModelImageMeta = DataModelImageMeta(Globals.apiImgUrl,
      //     Globals.apiImgUrl, Globals.apiitemclass, Globals.apiitems);
      // _save();
      // updateListView();
      // _incrementCounter();
      // navigateTo(context);
    });
  }

  void convertToString(ImageUploadResponse imageUploadResponse) {
    String metaItems = "";
    imageUploadResponse.items.forEach((oneItem) => {
          metaItems +=
              " ${oneItem.name}, ${oneItem.serve}, ${oneItem.weight}, ${oneItem.calorie}, ${oneItem.carbohydrates}, ${oneItem.fiber}, ${oneItem.fat}, ${oneItem.protein}, ${oneItem.sugar} | "
        });
    imageUploadResponse.itemMeta = metaItems;
  }

  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  File _image;
  File cimage;

  Future getImage(bool isCamera) async {
    File image;
    if (isCamera) {
      image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 70);
      await new Future.delayed(const Duration(seconds: 13), () {
        uploadImage(image);
        CircularProgressIndicator();
      });
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

  // databasehelper instance created
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<DataModelImageMeta> imageList;
  int count = 0;

  //save row to database

  //update list view for image
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

  void _save() async {
    //dataModelImageMeta.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (imageUploadResponse.id != null) {
      // Case 1: Update operation
      result = await databaseHelper.insertImageMeta(imageUploadResponse);
      print(result);
    } else {
      // Case 2: Insert Operation
      result = await databaseHelper.updateImage(dataModelImageMeta);
      print(result);
    }

    if (result != 0) {
      // Success
      debugPrint('saved successful image data');
    } else {
      // Failure
      debugPrint('Problem Saving saved successful image data');
    }
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
    var result = await databaseHelper.getAllRecords("imagetable");
    print(result);
    if (result != null) {
      sendDataToBlock(result);
    }
  }

  sendDataToBlock(List<dynamic> result) {
    var imgurl = "";
    List<ImageUploadResponse> lstImageUploadResponse =
        List<ImageUploadResponse>();
    for (var item in result) {
      ImageUploadResponse imageUploadResponse = ImageUploadResponse();
      imageUploadResponse.id = item["id"];
      imageUploadResponse.img_url = item["img_url"];
      imageUploadResponse.inf_img_url = item["inf_img_url"];
      imageUploadResponse.itemMeta = item["itemMeta"];
      lstImageUploadResponse.add(imageUploadResponse);
    }
    print(lstImageUploadResponse);
    print(imgurl);
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
          new StreamBuilder<List<ImageMetaData>>(
            stream: _imageDataBloc.imageListStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<ImageMetaData>> snapshot) {
              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Hero(
                        tag: snapshot.data[index].foodname,
                        child: Material(
                          child: InkWell(
                            onTap: () {
                              updateBlocList(this.imageList[index].items,
                                  this.imageList[index].imgurl);
                              navigateTo(context);
                            },
                            child: GridTile(
                              footer: Container(
                                color: Colors.black26,
                                child: ListTile(
                                  leading: Text(
                                    snapshot.data[index].foodname,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              child: Image.asset(
                                snapshot.data[index].imgurl,
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

// class ImageGridBuilder extends StatelessWidget {
//   const ImageGridBuilder({
//     Key key,
//     @required ImageDataBloc imageDataBloc, DatabaseHelper databaseHelper,
//   })  : _imageDataBloc = imageDataBloc,
//         super(key: key);

//   final ImageDataBloc _imageDataBloc;

//   @override
//   Widget build(BuildContext context) {
//     // return StreamBuilder<List<ImageMetaData>>(
//     //   stream: _imageDataBloc.imageListStream,
//     //   builder:
//     //       (BuildContext context, AsyncSnapshot<List<ImageMetaData>> snapshot) {
//     //     return GridView.builder(
//     //         gridDelegate:
//     //             SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//     //         itemCount: snapshot.data.length,
//     //         itemBuilder: (BuildContext context, int index) {
//     //           return Card(
//     //             child: Hero(
//     //               tag: snapshot.data[index].foodname,
//     //               child: Material(
//     //                 child: InkWell(
//     //                   onTap: () {
//     //                     updateBlocList(newItemList, imgurl)
//     //                     navigateTo(context);
//     //                   },
//     //                   child: GridTile(
//     //                     footer: Container(
//     //                       color: Colors.black26,
//     //                       child: ListTile(
//     //                         leading: Text(
//     //                           snapshot.data[index].foodname,
//     //                           style: TextStyle(
//     //                               fontWeight: FontWeight.bold,
//     //                               fontSize: 20,
//     //                               color: Colors.white),
//     //                         ),
//     //                       ),
//     //                     ),
//     //                     child: Image.asset(
//     //                       'images/pizza.jpg',
//     //                       fit: BoxFit.fill,
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ),
//     //             ),
//     //           );
//     //         });
//     //   },
//     // );
//   }

// }

Future updateBlocList(List newItemList, String imgurl) async {
  //TODO: update list in bloc file to use bloc pattern for state management
  List newItemList2 = newItemList;
  for (var i = 0; i < newItemList2.length; i++) {
    dynamic items = newItemList2[i];
    items.add(imgurl);
    newItemList2[i] = items;
  }
  Globals.changedImageMetaData = newItemList2;
  return Globals.changedImageMetaData;
}

Future navigateTo(context) async {
  Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => ImageDetails()));
}

Future processJsonResponse() async {
  print(Globals.apiResponse);
  Globals.apiData = Globals.apiResponse;
  //print(Globals.apiData);
  Globals.apiImgUrl = Globals.apiData['img_url'];
  // print(Globals.apiImgUrl);
  Globals.apiitems = Globals.apiData['items'];
  // print(Globals.apiitems);
  Globals.apiitemclass = Globals.apiData['item_class'];
//print(Globals.apiitemclass);
  Globals.apiitemCount = Globals.apiData['item_count'];
  //print(Globals.apiitemCount);
  return 1;
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

Future _incrementCounter() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Globals.counter = (prefs.getInt('counter') ?? 0) + 1;
  print('${Globals.counter} times.');
  await prefs.setInt('counter', Globals.counter);
  return 1;
}
