import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/database/DatabaseHelper.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/ui/SearchItem.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class ImageDetails extends StatefulWidget {
  final ImageUploadResponse imageUploadResponse;
  ImageDetails({@required this.imageUploadResponse});
  @override
  _ImageDetailsState createState() =>
      _ImageDetailsState(imageUploadResponse: imageUploadResponse);
}

class _ImageDetailsState extends State<ImageDetails>
    with WidgetsBindingObserver {
  DatabaseHelper databaseHelper = DatabaseHelper();

  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  final ImageUploadResponse imageUploadResponse;
  final ImageUploadMetaItems imageUploadMetaItems;
  _ImageDetailsState(
      {@required this.imageUploadResponse, this.imageUploadMetaItems});
  double serve;
  int counterToCheckMetaDataUpdate = 0;
  AppLifecycleState _notification;
  int touchedIndex;
  @override
  void initState() {
    super.initState();
    getMetaDetails();
    serve = 1;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
      switch (state) {
        case AppLifecycleState.resumed:
          print("// Handle this case");
          break;
        case AppLifecycleState.inactive:
          // Handle this case
          break;
        case AppLifecycleState.paused:
          // Handle this case
          break;
        case AppLifecycleState.suspending:
          // Handle this case
          break;
      }
    });
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
    _imageDataBloc.passDataToPieChartStream(updatedListOfImageMetaData);
    _imageDataBloc.passDataToImageList(updatedListOfImageMetaData);
  }

  deleteMetaRecordFromDb(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) async {
    final result = snapshot.data[index];
    print(result);
    var queryResult =
        await databaseHelper.deleteMetaFromImageMetaTable(result.id);
    print(queryResult);
    snapshot.data.removeAt(index);
    _imageDataBloc.passDataToImageList(snapshot.data);
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
      padding: EdgeInsets.only(left: 20, right: 20),
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

  void navigateToSearchItem(context, ImageUploadResponse imageUploadResponse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SearchItem(
          imageUploadResponse: imageUploadResponse,
        ),
      ),
    );
  }

  Widget btnToAddChangeField(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return ButtonTheme(
      minWidth: 2.0,
      height: 20.0,
      child: FlatButton(
        padding: EdgeInsets.only(left: 2, right: 2, top: 10, bottom: 10),
        onPressed: (() {
          print("run");
        }),
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget btnToAddDeleteField(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return ButtonTheme(
      minWidth: 2.0,
      height: 20.0,
      child: FlatButton(
        padding: EdgeInsets.only(left: 2, right: 2, top: 10, bottom: 10),
        onPressed: (() {
          deleteMetaRecordFromDb(snapshot, index);
        }),
        child: Icon(
          Icons.delete_forever,
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

  Widget btnPairEditDelete(
      AsyncSnapshot<List<ImageMetaData>> snapshot, int index) {
    return Row(
      children: <Widget>[
        // btnToAddChangeField(snapshot, index),
        btnToAddDeleteField(snapshot, index)
      ],
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
              Expanded(
                  flex: 5,
                  child: Container(
                      padding: EdgeInsets.only(left: 25),
                      child: cntForfoodName(snapshot, index))),
              Flexible(
                flex: 2,
                child: btnPairEditDelete(snapshot, index),
              )
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
                padding: const EdgeInsets.only(
                    left: 15, right: 10, top: 10, bottom: 10),
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
              onPressed: (() {
                navigateToSearchItem(context, imageUploadResponse);
              }),
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

  Widget indicator() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: new Color.fromRGBO(241, 241, 241, 0.5)),
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

  Widget imageDetailStreamBuilder() {
    return StreamBuilder<List<ImageMetaData>>(
        stream: _imageDataBloc.imageListStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ImageMetaData>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return lstBuilderForImageMetaItems(snapshot);
          }
          return indicator();
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
    return GestureDetector(
      onTap: () {
        dialog();
        //TODO: Popupto View image
      },
      child: Container(
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          image: DecorationImage(
            fit: BoxFit.fill,
            image: MemoryImage(
              base64Decode(imageUploadResponse.base64InfImage),
            ),
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
        child: Icon(
          Icons.arrow_left,
          color: Colors.white,
        ));
  }

  Widget mainTitle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 80.0),
        child: Text(
          "Nutritonal values",
          style: TextStyle(
              color: Colors.white, //Color.fromRGBO(45, 46, 51, 1),
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

  Widget barChartBuilder(AsyncSnapshot<List<ImageMetaData>> snapshot) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Colors.transparent,
        child: BarChart(
          BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: getTotalCarbohydrates(snapshot.data) +
                  getTotalCalories(snapshot.data) +
                  getTotalFats(snapshot.data) +
                  getTotalProtein(snapshot.data) +
                  100,
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.transparent,
                  tooltipPadding: const EdgeInsets.all(0),
                  tooltipBottomMargin: 8,
                  getTooltipItem: (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
                    return BarTooltipItem(
                      rod.y.round().toString(),
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  showTitles: true,
                  textStyle: TextStyle(
                      color: Colors.white, //const Color(0xff7589a2),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  margin: 20,
                  getTitles: (double value) {
                    switch (value.toInt()) {
                      case 0:
                        return 'Cal';
                      case 1:
                        return 'Carb';
                      case 2:
                        return 'Fat';
                      case 3:
                        return 'Pro';
                      default:
                        return '';
                    }
                  },
                ),
                leftTitles: const SideTitles(showTitles: false),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: [
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(
                      y: getTotalCarbohydrates(snapshot.data),
                      color: Colors.white)
                ], showingTooltipIndicators: [
                  0
                ]),
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(
                      y: getTotalCalories(snapshot.data), color: Colors.white)
                ], showingTooltipIndicators: [
                  0
                ]),
                BarChartGroupData(x: 2, barRods: [
                  BarChartRodData(
                      y: getTotalFats(snapshot.data), color: Colors.white)
                ], showingTooltipIndicators: [
                  0
                ]),
                BarChartGroupData(x: 3, barRods: [
                  BarChartRodData(
                      y: getTotalProtein(snapshot.data), color: Colors.white)
                ], showingTooltipIndicators: [
                  0
                ]),
              ]),
        ),
      ),
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
            onPressed: () {
              navigateToSearchItem(context, imageUploadResponse);
            },
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      AsyncSnapshot<List<ImageMetaData>> snapshot) {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: 30,
            title: getTotalCarbohydrates(snapshot.data),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: 35,
            title: getTotalCalories(snapshot.data),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: 15,
            title: getTotalFats(snapshot.data),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: 20,
            title: getTotalProtein(snapshot.data),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          return null;
      }
    });
  }

  getTotalCarbohydrates(List<ImageMetaData> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.cal)
          .toList()
          .reduce((combine, next) => combine + next)
          .truncateToDouble();
    }
    return item != null ? item : "0";
  }

  getTotalFats(List<ImageMetaData> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.fat)
          .toList()
          .reduce((combine, next) => combine + next)
          .truncateToDouble();
    }
    return item != null ? item : "0";
  }

  Widget textIndicator(var colorcode, String pieChartDataType) {
    return Row(
      children: <Widget>[
        Container(
          height: 15,
          width: 15,
          color: Color(colorcode),
        ),
        Text("\t\t$pieChartDataType"),
      ],
    );
  }

  getTotalProtein(List<ImageMetaData> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.protin)
          .toList()
          .reduce((combine, next) => combine + next)
          .truncateToDouble();
    }
    return item != null ? item : "0";
  }

  getTotalCalories(List<ImageMetaData> imageUploadResponseList) {
    var item;
    if (imageUploadResponseList != null && imageUploadResponseList.isNotEmpty) {
      item = imageUploadResponseList
          .map((item) => item.card)
          .toList()
          .reduce((combine, next) => combine + next)
          .truncateToDouble();
    }
    return item != null ? item : "0";
  }

  Widget barChartWidget() {
    return StreamBuilder<List<ImageMetaData>>(
        stream: _imageDataBloc.pieChartDataStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ImageMetaData>> snapshot) {
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 0,
            color: Colors.transparent,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: imageViewContainer(),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: barChartBuilder(snapshot),
                  ),
                ),
              ],
            ),
          );
        });
  }

  dialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                height: MediaQuery.of(context).size.height / 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: MemoryImage(
                      base64Decode(imageUploadResponse.base64InfImage),
                    ),
                  ),
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _willPopCallback(),
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  child:
                      new Image.asset('images/screen2.png', fit: BoxFit.cover)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(height: 30),
                  titleHolder(),
                  Expanded(
                    flex: 1,
                    child: barChartWidget(),
                  ),
                  Expanded(
                    flex: 2,
                    child: imageDetailStreamBuilder(),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: cntFabAddFoodItem(),
        ));
  }
}
