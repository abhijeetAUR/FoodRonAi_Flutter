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
                                      style: TextStyle(fontSize: 25),
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
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, left: 30),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '${Globals.serve} :\t',
                                        style: TextStyle(fontSize: 22),
                                      ),
                                      Text(
                                        '${snapshot.data[index].serve}',
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ],
                                  )),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    padding: new EdgeInsets.only(left: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '\n${Globals.weight} :\t${snapshot.data[index].weight} \n',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        Text(
                                          '${Globals.calorie} :\t${snapshot.data[index].cal} \n',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                        Text(
                                          '${Globals.carbohydrates} :\t${snapshot.data[index].card} \n',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                        Text(
                                          '${Globals.protein} :\t${snapshot.data[index].protin} \n',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    padding: new EdgeInsets.only(
                                        left: 30, right: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '\n${Globals.fat} :\t${snapshot.data[index].fat} \n',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        Text(
                                          '${Globals.fiber} :\t${snapshot.data[index].fiber} \n',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                        Text(
                                          '${Globals.sugar} :\t${snapshot.data[index].suger} \n',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
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
          Flexible(flex: 2, child: imageViewContainer()),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: imageItemDetailCard(),
          )
        ],
      ),
    );
  }
}
