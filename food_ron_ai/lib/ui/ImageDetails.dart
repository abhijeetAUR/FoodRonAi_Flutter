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

  Widget imageItemDetailCard() {
    return StreamBuilder<List<ImageMetaData>>(
        stream: _imageDataBloc.imageListStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ImageMetaData>> snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Hero(
                  tag: snapshot.data[index].foodname,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(30))),
                    child: InkWell(
                      onTap: () {},
                      child: GridTile(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              new Container(
                                padding: new EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      capitalizeName(
                                          snapshot.data[index].foodname),
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontFamily: 'HelveticaNeue',
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(width: 20.0),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                child: Slider.adaptive(
                                  // key: UniqueKey(),
                                  activeColor: Colors.orangeAccent,
                                  value: snapshot.data[index].serve
                                      .truncateToDouble(),
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  label: "$serve",
                                  onChanged: (double newServe) {
                                    setState(() {
                                      serve = newServe.round();
                                    });
                                    Globals.servecount = serve;
                                    _imageDataBloc.imageServeIncrement
                                        .add(snapshot.data[index]);
                                  },
                                ),
                              ),
                              //------------------

                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20.0),
                                height: 110,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          // Where the linear gradient begins and ends
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          // Add one stop for each color. Stops should increase from 0 to 1
                                          stops: [0.1, 0.3, 0.6, 0.9],
                                          colors: [
                                            // Colors are easy thanks to Flutter's Colors class.
                                            Colors.orange[800],
                                            Colors.orange[700],
                                            Colors.orange[500],
                                            Colors.orange[300],
                                          ],
                                        ),
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 5),
                                      width: 110.0,
                                      child: Column(
                                        children: <Widget>[
                                          Text("${snapshot.data[index].serve}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontFamily: 'HelveticaNeue',
                                                fontWeight: FontWeight.w900,
                                              )),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 3,
                                                  right: 3,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Text("S E R V E",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'HelveticaNeue',
                                                      fontWeight:
                                                          FontWeight.w700))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          // Where the linear gradient begins and ends
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          // Add one stop for each color. Stops should increase from 0 to 1
                                          stops: [0.1, 0.3, 0.6, 0.9],
                                          colors: [
                                            // Colors are easy thanks to Flutter's Colors class.
                                            Colors.orange[800],
                                            Colors.orange[700],
                                            Colors.orange[500],
                                            Colors.orange[300],
                                          ],
                                        ),
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 5),
                                      width: 125.0,
                                      child: Column(
                                        children: <Widget>[
                                          Text("${snapshot.data[index].weight}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontFamily: 'HelveticaNeue',
                                                fontWeight: FontWeight.w900,
                                              )),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 3,
                                                  right: 3,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Text("W E I G H T",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'HelveticaNeue',
                                                      fontWeight:
                                                          FontWeight.w700))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          // Where the linear gradient begins and ends
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          // Add one stop for each color. Stops should increase from 0 to 1
                                          stops: [0.1, 0.3, 0.6, 0.9],
                                          colors: [
                                            // Colors are easy thanks to Flutter's Colors class.
                                            Colors.orange[800],
                                            Colors.orange[700],
                                            Colors.orange[500],
                                            Colors.orange[300],
                                          ],
                                        ),
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 5),
                                      width: 130.0,
                                      child: Column(
                                        children: <Widget>[
                                          Text("${snapshot.data[index].cal}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontFamily: 'HelveticaNeue',
                                                fontWeight: FontWeight.w900,
                                              )),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 3,
                                                  right: 3,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Text("C A L O R I E",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'HelveticaNeue',
                                                      fontWeight:
                                                          FontWeight.w700))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          // Where the linear gradient begins and ends
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          // Add one stop for each color. Stops should increase from 0 to 1
                                          stops: [0.1, 0.3, 0.6, 0.9],
                                          colors: [
                                            // Colors are easy thanks to Flutter's Colors class.
                                            Colors.orange[800],
                                            Colors.orange[700],
                                            Colors.orange[500],
                                            Colors.orange[300],
                                          ],
                                        ),
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 5),
                                      width: 120.0,
                                      child: Column(
                                        children: <Widget>[
                                          Text("${snapshot.data[index].card}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontFamily: 'HelveticaNeue',
                                                fontWeight: FontWeight.w900,
                                              )),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 3,
                                                  right: 3,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Text("C A R B ' S",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'HelveticaNeue',
                                                      fontWeight:
                                                          FontWeight.w700))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          // Where the linear gradient begins and ends
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          // Add one stop for each color. Stops should increase from 0 to 1
                                          stops: [0.1, 0.3, 0.6, 0.9],
                                          colors: [
                                            // Colors are easy thanks to Flutter's Colors class.
                                            Colors.orange[800],
                                            Colors.orange[700],
                                            Colors.orange[500],
                                            Colors.orange[300],
                                          ],
                                        ),
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 5),
                                      width: 90.0,
                                      child: Column(
                                        children: <Widget>[
                                          Text("${snapshot.data[index].fat}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontFamily: 'HelveticaNeue',
                                                fontWeight: FontWeight.w900,
                                              )),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 3,
                                                  right: 3,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Text("F A T",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'HelveticaNeue',
                                                      fontWeight:
                                                          FontWeight.w700))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          // Where the linear gradient begins and ends
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          // Add one stop for each color. Stops should increase from 0 to 1
                                          stops: [0.1, 0.3, 0.6, 0.9],
                                          colors: [
                                            // Colors are easy thanks to Flutter's Colors class.
                                            Colors.orange[800],
                                            Colors.orange[700],
                                            Colors.orange[500],
                                            Colors.orange[300],
                                          ],
                                        ),
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 5),
                                      width: 115.0,
                                      child: Column(
                                        children: <Widget>[
                                          Text("${snapshot.data[index].protin}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontFamily: 'HelveticaNeue',
                                                fontWeight: FontWeight.w900,
                                              )),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 3,
                                                  right: 3,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Text("P R O T I N",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'HelveticaNeue',
                                                      fontWeight:
                                                          FontWeight.w700))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          // Where the linear gradient begins and ends
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          // Add one stop for each color. Stops should increase from 0 to 1
                                          stops: [0.1, 0.3, 0.6, 0.9],
                                          colors: [
                                            // Colors are easy thanks to Flutter's Colors class.
                                            Colors.orange[800],
                                            Colors.orange[700],
                                            Colors.orange[500],
                                            Colors.orange[300],
                                          ],
                                        ),
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 5),
                                      width: 105.0,
                                      child: Column(
                                        children: <Widget>[
                                          Text("${snapshot.data[index].fiber}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontFamily: 'HelveticaNeue',
                                                fontWeight: FontWeight.w900,
                                              )),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 3,
                                                  right: 3,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Text("F I B E R",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'HelveticaNeue',
                                                      fontWeight:
                                                          FontWeight.w700))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          // Where the linear gradient begins and ends
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          // Add one stop for each color. Stops should increase from 0 to 1
                                          stops: [0.1, 0.3, 0.6, 0.9],
                                          colors: [
                                            // Colors are easy thanks to Flutter's Colors class.
                                            Colors.orange[800],
                                            Colors.orange[700],
                                            Colors.orange[500],
                                            Colors.orange[300],
                                          ],
                                        ),
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 5),
                                      width: 105.0,
                                      child: Column(
                                        children: <Widget>[
                                          Text("${snapshot.data[index].suger}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontFamily: 'HelveticaNeue',
                                                fontWeight: FontWeight.w900,
                                              )),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 3,
                                                  right: 3,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Text("S U G E R",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'HelveticaNeue',
                                                      fontWeight:
                                                          FontWeight.w700))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //---------------------
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  _saveButtonClicked() async {
    print("Inside save");
    updateRecordsOfMetaData();
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
    //TODO:Change to network image
    return Image.network(
      imageUploadResponse.inf_img_url,
      fit: BoxFit.cover,
    );
  }

  Widget imageViewContainer() {
    return Container(
      //height: 300,
      child: new SizedBox(
        width: double.infinity,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: imageUpdateWidget(),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50))
              //BorderRadius.circular(25),
              ),
          elevation: 5,
          margin: EdgeInsets.only(bottom: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Center(
          child: Text(
            "Image Detail",
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          // action button
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.save),
            onPressed: () {
              _saveButtonClicked();
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 2, child: imageViewContainer()),
          Expanded(
            flex: 2,
            child: imageItemDetailCard(),
          )
        ],
      ),
    );
  }
}
