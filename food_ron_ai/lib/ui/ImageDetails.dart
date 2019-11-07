import 'package:flutter/material.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/customwidgets/CardDetailsView.dart';
import 'package:food_ron_ai/database/DatabaseHelper.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import '../Global.dart';
import 'package:food_ron_ai/Global.dart' as Globals;

class ImageDetails extends StatefulWidget {
  final ImageUploadResponse imageUploadResponse;
  ImageDetails({@required this.imageUploadResponse});
  @override
  _ImageDetailsState createState() =>
      _ImageDetailsState(imageUploadResponse: imageUploadResponse);
}

class _ImageDetailsState extends State<ImageDetails> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  final ImageUploadResponse imageUploadResponse;
  _ImageDetailsState({@required this.imageUploadResponse});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getMetaDetails();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _imageDataBloc.dispose();
    super.dispose();
  }

  _saveButtonClicked() async {
    print("Inside save");
    // var result = await databaseHelper.updateImage(Globals.metaData[0]);
    // print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("$appName"),
        ),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveButtonClicked();
            },
          )
        ],
      ),
      body: DetailView(
        imageUploadResponse: imageUploadResponse,
      ),
    );
  }
}

class DetailView extends StatelessWidget {
  final ImageUploadResponse imageUploadResponse;
  DetailView({@required this.imageUploadResponse});

//REFER THIS
  Widget imageUpdateWidget() {
    return Image.network(
      imageUploadResponse.inf_img_url,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(
              child: new SizedBox(
            width: double.infinity,
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: imageUpdateWidget(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(10),
            ),
          )),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: CardDetailsView(
              imageUploadResponse: imageUploadResponse,
            ),
          ),
        )
      ],
    );
  }
}
