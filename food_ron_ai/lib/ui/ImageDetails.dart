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
                            BorderRadius.all(Radius.circular(40))),
                    child: InkWell(
                      onTap: () {},
                      child: GridTile(
                        child: Container(
                          decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // Where the linear gradient begins and ends
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    // Add one stop for each color. Stops should increase from 0 to 1
                    stops: [0.1, 0.3, 0.6, 0.9],
                    colors: [
                      // Colors are easy thanks to Flutter's Colors class.
                      Colors.orange[300],
                      Colors.orange[400],
                      Colors.orange[500],
                      Colors.orange[600],
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                          child: Column(  
                            children: <Widget>[
                              new Container(
                                padding: new EdgeInsets.only(top: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      capitalizeName(
                                          snapshot.data[index].foodname),
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontFamily: 'HelveticaNeue',
                                          fontWeight: FontWeight.w600,color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(width: 20.0),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10),
                                child: Slider.adaptive(
                                  // key: UniqueKey(),
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white24,
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
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex:2,
                                    child: Container(
                                      
                                      child: Center(
                                        child: Text("${Globals.serve}\n${Globals.weight}\n${Globals.calorie}\n${Globals.carbohydrates}\n${Globals.protein}\n${Globals.fat}\n${Globals.fiber}\n${Globals.sugar}\n",style: TextStyle(fontSize: 18,fontFamily: 'HelveticaNeue',fontWeight: FontWeight.w500,color: Colors.white),),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex:2,
                                    child: Container(
                                      child: Center(
                                        child: Text("${snapshot.data[index].serve}\n${snapshot.data[index].weight}\n${snapshot.data[index].cal}\n${snapshot.data[index].card}\n${snapshot.data[index].protin}\n${snapshot.data[index].fat}\n${snapshot.data[index].fiber}\n${snapshot.data[index].suger}\n",style: TextStyle(fontSize: 18,fontFamily: 'HelveticaNeue',fontWeight: FontWeight.w500,color: Colors.white),),
                                      ),
                                    ),
                                  ),
                                  
                                ],
                              )
                              
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
              borderRadius: BorderRadius.all(Radius.circular(25))
              //BorderRadius.circular(25),
              ),
          elevation: 5,
          margin: EdgeInsets.all(5),
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
