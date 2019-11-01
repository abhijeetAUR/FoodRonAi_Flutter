import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/database/SqlConnection.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:food_ron_ai/ui/ImageDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:sqflite/sqlite_api.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //TODO: file upload image funtion.

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
      print(value);
      Globals.apiResponse = json.decode(value);
      processJsonResponse();
      dbHelper.insert(Globals.apiitems);
      navigateTo(context);
    });
  }

  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  File _image;
  File cimage;

  Future getImage(bool isCamera) async {
    File image;
    if (isCamera) {
      image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 70);
      //cimage= compressImage(image) as File;
      uploadImage(image);
      Timer(Duration(seconds: 15), () {
        navigateTo(context);
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

  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Globals.topAppBar,
      // body: FoodItems(),
      body: Stack(
        children: <Widget>[
          new ImageGridBuilder(imageDataBloc: _imageDataBloc),
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

class ImageGridBuilder extends StatelessWidget {
  const ImageGridBuilder({
    Key key,
    @required ImageDataBloc imageDataBloc,
  })  : _imageDataBloc = imageDataBloc,
        super(key: key);

  final ImageDataBloc _imageDataBloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ImageMetaData>>(
      stream: _imageDataBloc.imageListStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<ImageMetaData>> snapshot) {
        return GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: Hero(
                  tag: snapshot.data[index].foodname,
                  child: Material(
                    child: InkWell(
                      onTap: () {
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
                          'images/pizza.jpg',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}

Future navigateTo(context) async {
  Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => ImageDetails()));
}

void processJsonResponse() {
  print(Globals.apiResponse);
  Globals.apiData = Globals.apiResponse['data'];
  //print(Globals.apiData);
  Globals.apiImgUrl = Globals.apiData['imgurl'];
  // print(Globals.apiImgUrl);
  Globals.apiitems = Globals.apiData['items'];
  // print(Globals.apiitems);
  Globals.apiitemclass = Globals.apiData['item_class'];
//print(Globals.apiitemclass);
  Globals.apiitemCount = Globals.apiData['item_count'];
  //print(Globals.apiitemCount);
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
