import 'package:flutter/material.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/database/DatabaseHelper.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
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
  int serve;
  int counterToCheckMetaDataUpdate = 0;

  @override
  void initState() {
    super.initState();
    getMetaDetails();
    serve = 1;
  }

  @override
  void dispose() {
    _imageDataBloc.dispose();
    super.dispose();
  }

  void getMetaDetails() async {
    var result =
        await databaseHelper.getAllMetaRecords(imageUploadResponse.itemMetaId);
    print(result);

    List<ImageMetaData> updatedListOfImageMetaData = List<ImageMetaData>();
    for (var item in result) {
      ImageMetaData imageMetaData = ImageMetaData();
      imageMetaData = ImageMetaData.fromJson(item);
      updatedListOfImageMetaData.add(imageMetaData);
    }
    _imageDataBloc.passDataToImageList(updatedListOfImageMetaData);
  }

  capitalizeName(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }

  navigateToHomePage() {
    updateRecordsOfMetaData();
    Navigator.of(context).pop(true);
  }

  Future<bool> _willPopCallback() {
    return showDialogForSavingMetaData();
  }

  Future<bool> showDialogForSavingMetaData() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Save changes'),
            content:
                new Text('Do you want to save the changed serve quantity?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => {
                  updateRecordsOfMetaData(),
                  Navigator.of(context).pop(true)
                },
                child: new Text('Yes'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('No'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget cntForfoodName(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 35.0),
      child: Text(capitalizeName(snapshot.data[index].foodname),
          style: TextStyle(
              fontSize: 26,
              color: Color.fromRGBO(189, 189, 221, 1),
              fontFamily: 'HelveticaNeue',
              fontWeight: FontWeight.w700)),
    );
  }

  Widget sliderForServerCount(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Slider.adaptive(
        key: UniqueKey(),
        activeColor: Color.fromRGBO(69, 150, 80, 1),
        inactiveColor: Color.fromRGBO(109, 190, 80, 1),
        value: snapshot.data[index].serve.truncateToDouble(),
        min: 1,
        max: 10,
        divisions: 9,
        label: "$serve",
        onChanged: (double newServe) {
          setState(() {
            serve = newServe.round();
          });
          Globals.servecount = serve;
          _imageDataBloc.imageServeIncrement.add(snapshot.data[index]);
        },
      ),
    );
  }

  Widget rowForMetaNameAndSlider(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Row(
      children: <Widget>[
        Expanded(child: cntForfoodName(snapshot, index)),
        Expanded(child: sliderForServerCount(snapshot, index))
      ],
    );
  }

  Widget cntForMetaDataFieldNames(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Container(
      child: Center(
        child: Text(
          "${Globals.serve}\n${Globals.weight}\n${Globals.calorie}\n${Globals.carbohydrates}\n${Globals.protein}\n${Globals.fat}\n${Globals.fiber}\n${Globals.sugar}\n",
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'HelveticaNeue',
              fontWeight: FontWeight.w500,
              color: Colors.black),
        ),
      ),
    );
  }

  Widget cntForMetaDataFieldValues(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Container(
      child: Center(
        child: Text(
          "${snapshot.data[index].serve}\n${snapshot.data[index].weight}\n${snapshot.data[index].cal}\n${snapshot.data[index].card}\n${snapshot.data[index].protin}\n${snapshot.data[index].fat}\n${snapshot.data[index].fiber}\n${snapshot.data[index].suger}\n",
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'HelveticaNeue',
              fontWeight: FontWeight.w500,
              color: Colors.black),
        ),
      ),
    );
  }

  Widget rowForFoodMetaData(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(flex: 1, child: cntForMetaDataFieldNames(snapshot, index)),
          Expanded(flex: 1, child: cntForMetaDataFieldValues(snapshot, index)),
        ],
      ),
    );
  }

  Widget lstBuilderForImageMetaItems(
      AsyncSnapshot<List<ImageMetaData>> snapshot) {
    return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(
                left: 24.0, right: 24.0, top: 8, bottom: 8),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              elevation: 5,
              margin: EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    rowForMetaNameAndSlider(snapshot, index),
                    rowForFoodMetaData(snapshot, index)
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget imageDetailStreamBuilder() {
    return StreamBuilder<List<ImageMetaData>>(
        stream: _imageDataBloc.imageListStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ImageMetaData>> snapshot) {
          return lstBuilderForImageMetaItems(snapshot);
        });
  }

  updateRecordsOfMetaData() async {
    if (Globals.metaData.length != counterToCheckMetaDataUpdate) {
      var result = await databaseHelper
          .updateImage(Globals.metaData[counterToCheckMetaDataUpdate]);
      if (result != null) {
        counterToCheckMetaDataUpdate += 1;
        updateRecordsOfMetaData();
      }
    }
  }

  Widget imageUpdateWidget() {
    return Image.network(
      imageUploadResponse.infImgUrl,
      fit: BoxFit.cover,
    );
  }

  Widget imageViewContainer() {
    return Container(
      child: new SizedBox(
        width: double.infinity,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: imageUpdateWidget(),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          elevation: 5,
          margin: EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 0),
        ),
      ),
    );
  }

  Widget backArrow() {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 10),
      child: GestureDetector(
        onTap: (() {
          navigateToHomePage();
        }),
        child: Icon(Icons.arrow_left),
      ),
    );
  }

  Widget mainTitle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: Text(
          "Nutritonal values",
          style: TextStyle(
              color: Color.fromRGBO(45, 46, 51, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget saveButton() {
    return Icon(Icons.save);
  }

  Widget titleHolder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 0,
          child: backArrow(),
        ),
        Expanded(flex: 1, child: mainTitle()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _willPopCallback(),
      child: Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(height: 60),
            titleHolder(),
            SizedBox(height: 20),
            Expanded(flex: 1, child: imageViewContainer()),
            Expanded(
              flex: 1,
              child: imageDetailStreamBuilder(),
            )
          ],
        ),
      ),
    );
  }
}
