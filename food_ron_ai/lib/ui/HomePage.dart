import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:food_ron_ai/ui/ImageDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //TODO: file upload image funtion.

  void uploadFile(filePath) async {
    // Get base file name
    String fileName = basename(filePath.path);
    print("File base name: $fileName");

    try {
      FormData formData = new FormData.fromMap({
        "async": true,
  "crossDomain": true,
  "url": "http://api.foodron.ai/v1.0/uploadimg",
  "method": "POST",
  "headers": {
    "authorization": "96331CA0-7959-402E-8016-B7ABB3287A16",
  },
  "processData": false,
  "contentType": false,
  "mimeType": "multipart/form-data",
  "data": "form"
      });

      Response response =
          await Dio().post("${Globals.imguploadurl}", data: formData);
      print("File upload response: $response");

      // Show the incoming message in snakbar
      print(response.data['message']);
    } catch (e) {
      print("Exception Caught: $e");
    }
  }

  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  File _image;

  Future getImage(bool isCamera) async {
    File image;
    if (isCamera) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
      uploadFile(image);
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
                  navigateTo(context);
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
  Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (BuildContext context) => ImageDetails()));
}
