import 'dart:math';

import 'package:flutter/material.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';

class CardDetailsView extends StatefulWidget {
  @override
  _CardDetailsViewState createState() => _CardDetailsViewState();
}

class _CardDetailsViewState extends State<CardDetailsView> {
  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  double serve = 1;
  @override
  void dispose() {
    // TODO: implement dispose
    _imageDataBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ImageMetaData>>(
        stream: _imageDataBloc.imageListStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ImageMetaData>> snapshot) {
          return GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: Hero(
                  tag: snapshot.data[index].foodname,
                  child: Material(
                    child: InkWell(
                      onTap: () {},
                      child: GridTile(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              new Container(
                                padding: new EdgeInsets.only(top: 13),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      snapshot.data[index].foodname,
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20.0),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 2, right: 2, top: 10),
                                    child: Slider(
                                      activeColor: Colors.orangeAccent,
                                      value: serve,
                                      onChanged: (newServe){
                                        setState(() {
                                         serve= newServe ; 
                                        });  
                                      },
                                      min: 1,
                                      max: 10,
                                      divisions: 10,
                                      label: "$serve",
                                    ),
                                // child: WaveSlider(
                                //   onChanged: (double val) {
                                //     setState(() {
                                //       serve = (val * 10).round();
                                     
                                //     });
                                //     Globals.servecount=serve;
                                //      _imageDataBloc.imageServeIncrement.add(snapshot.data[index]);
                                //   },
                                // ),
                              ),
                              SizedBox(width: 20.0),
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, left: 30),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '${Globals.serve} :\t',
                                        style: TextStyle(fontSize: 25.0),
                                      ),
                                      Text(
                                        serve.toString(),
                                        style: TextStyle(fontSize: 25.0),
                                      ),
                                    ],
                                  )),
                              SizedBox(width: 20.0),
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
                                        SizedBox(width: 20.0),
                                        Text(
                                          '\n${Globals.weight} :\t${snapshot.data[index].weight} \n',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        SizedBox(width: 20.0),
                                        Text(
                                          '${Globals.calorie} :\t${snapshot.data[index].cal} \n',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                        SizedBox(width: 20.0),
                                        Text(
                                          '${Globals.carbohydrates} :\t${snapshot.data[index].card} \n',
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
                                        SizedBox(width: 20.0),
                                        Text(
                                          '\n${Globals.fat} :\t${snapshot.data[index].fat} \n',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        SizedBox(width: 20.0),
                                        Text(
                                          '${Globals.fiber} :\t${snapshot.data[index].fiber} \n',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                        SizedBox(width: 20.0),
                                        Text(
                                          '${Globals.sugar} :\t${snapshot.data[index].suger} \n',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: new EdgeInsets.only(
                                        right: 5),
                                child: Text(
                                          '${Globals.protein} :\t${snapshot.data[index].protin} \n',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                              )
                              // Row(
                              //   children: <Widget>[
                              //     Text(
                              //               '\n${Globals.protein} :\t${snapshot.data[index].protin} \n',
                              //               style: TextStyle(fontSize: 20.0),
                              //             ),
                              //   ],
                              // )
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
}
