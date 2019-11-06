import 'package:flutter/material.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/customwidgets/CardDetailsView.dart';
import 'package:food_ron_ai/database/DatabaseHelper.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import '../Global.dart';

class ImageDetails extends StatefulWidget {
  final ImageUploadResponse imageUploadResponse;
  ImageDetails({@required this.imageUploadResponse});
  @override
  _ImageDetailsState createState() =>
      _ImageDetailsState(imageUploadResponse: imageUploadResponse);
}

class _ImageDetailsState extends State<ImageDetails> {
  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  final ImageUploadResponse imageUploadResponse;
  _ImageDetailsState({@required this.imageUploadResponse});
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMetaDetails();
  }

  void getMetaDetails() async {
    var result =
        await databaseHelper.getAllMetaRecords(imageUploadResponse.itemMetaId);
    print(result);

    List<ImageMetaData> updatedListOfImageMetaData =
        List<ImageMetaData>();
    for (var item in result) {
      ImageMetaData imageMetaData = ImageMetaData();
      imageMetaData.id = item["itemMetaId"];
      imageMetaData.foodname = item["name"];
      imageMetaData.serve = item["serve"];
      imageMetaData.weight = item["weight"];
      imageMetaData.cal = item["calorie"];
      imageMetaData.card = item["carbohydrates"];
      imageMetaData.fiber = item["fiber"];
      imageMetaData.fat = item["fat"];
      imageMetaData.protin = item["protein"];
      imageMetaData.suger = item["sugar"];
      updatedListOfImageMetaData.add(imageMetaData);
    }

    _imageDataBloc.passDataToImageList(updatedListOfImageMetaData);

    //TODO: implement same as sendDataTOBlock
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
      appBar: topAppBar,
      body: DetailView(
        imageUploadResponse: imageUploadResponse,
      ),
    );
  }
}

class DetailView extends StatelessWidget {
  final ImageUploadResponse imageUploadResponse;
  DetailView({@required this.imageUploadResponse});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Card(
            child: Image.network(
              imageUploadResponse.img_url,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: CardDetailsView(),
          ),
        )
      ],
    );
  }
}
