import 'dart:convert';

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
  double serve;
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

  Widget cntForMetaDataFieldNames(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return SizedBox(
      child: Center(
        child: DataTable(
          dataRowHeight: 25,
          headingRowHeight: 0,
          columnSpacing: 25,
          columns: [
            DataColumn(label: Text("")),
            DataColumn(label: Text("")),
            DataColumn(label: Text("")),
            DataColumn(label: Text("")),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text("${Globals.serve}")),
              DataCell(Text("${snapshot.data[index].serve}")),
              DataCell(Text("${Globals.protein}")),
              DataCell(Text("${snapshot.data[index].protin}")),
            ]),
            DataRow(cells: [
              DataCell(Text("${Globals.weight}")),
              DataCell(Text("${snapshot.data[index].weight}")),
              DataCell(Text("${Globals.fat}")),
              DataCell(Text("${snapshot.data[index].fat}")),
            ]),
            DataRow(cells: [
              DataCell(Text("${Globals.calorie}")),
              DataCell(Text("${snapshot.data[index].cal}")),
              DataCell(Text("${Globals.fiber}")),
              DataCell(Text("${snapshot.data[index].fiber}")),
            ]),
            DataRow(cells: [
              DataCell(Text("${Globals.carbohydrates}")),
              DataCell(Text("${snapshot.data[index].card}")),
              DataCell(Text("${Globals.sugar}")),
              DataCell(Text("${snapshot.data[index].suger}")),
            ]),
          ],
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
              fontSize: 16,
              fontFamily: 'HelveticaNeue',
              fontWeight: FontWeight.w500,
              color: Colors.black),
        ),
      ),
    );
  }

  Widget sliderForServerCount(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Container(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Center(
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
              serve = newServe;
            });
            Globals.servecount = serve;
            _imageDataBloc.imageServeIncrement.add(snapshot.data[index]);
          },
        ),
      ),
    );
  }

  Widget btnToAddChangeField() {
    return ButtonTheme(
      minWidth: 10.0,
      height: 20.0,
      child: FlatButton(
        onPressed: (() {
          print("run");
        }),
        child: Icon(
          Icons.edit,
          color: Colors.black54,
          size: 20,
        ),
      ),
    );
  }

  Widget cntForfoodName(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(capitalizeName(snapshot.data[index].foodname),
          style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontFamily: 'HelveticaNeue',
              fontWeight: FontWeight.w700)),
    );
  }

  Widget rowForMetaNameAndSliderAndEditBtn(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Container(
      height: 98,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(flex: 4, child: Container(padding: EdgeInsets.only(left: 30),child: cntForfoodName(snapshot, index))),
              Expanded(flex: 2, child: btnToAddChangeField()),
            ],
          ),
          sliderForServerCount(snapshot, index),
        ],
      ),
    );
  }

  Widget rowForFoodMetaData(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(flex: 1, child: cntForMetaDataFieldNames(snapshot, index)),
          // Expanded(flex: 2, child: cntForMetaDataFieldValues(snapshot, index)),
        ],
      ),
    );
  }

  Widget lstBuilderForImageMetaItems(
      AsyncSnapshot<List<ImageMetaData>> snapshot) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.data.length,
        //physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(
                left: 24.0, right: 24.0, top: 0, bottom: 8),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              elevation: 5,
              margin: EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.only(left: 15,right: 10,top: 10,bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    rowForMetaNameAndSliderAndEditBtn(snapshot, index),
                    rowForFoodMetaData(snapshot, index),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget addNewMetaData() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24, top: 16),
      child: Row(
        children: <Widget>[
          FlatButton(
              onPressed: (() {}),
              child: Icon(Icons.add, color: Color.fromRGBO(69, 150, 80, 1))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Add new food item which \nis not recognized?",
                style: TextStyle(
                    color: Color.fromRGBO(69, 150, 80, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
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

  Widget imageViewContainer() {
    return Container(
      //width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        
        borderRadius: BorderRadius.all(Radius.circular(10)),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: MemoryImage(
            base64Decode(imageUploadResponse.base64InfImage),
          ),
        ),
      ),
    );
  }

  Widget backArrow() {
    return FlatButton(
        onPressed: (() {
          navigateToHomePage();
        }),
        child: Icon(Icons.arrow_left));
  }

  Widget mainTitle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 80.0),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 0,
          child: backArrow(),
        ),
        Expanded(flex: 1, child: mainTitle()),
      ],
    );
  }

  Widget cntFabAddFoodItem() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          backgroundColor: Color.fromRGBO(69, 150, 80, 1),
          splashColor: Colors.green,
          child: FlatButton(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {},
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _willPopCallback(),
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 30),
              titleHolder(),
              Expanded(
                flex: 1,
                child: imageViewContainer(),
              ),
              Expanded(
                flex: 2,
                child: imageDetailStreamBuilder(),
              ),
            ],
          ),
          floatingActionButton: cntFabAddFoodItem(),
        ));
  }
}
