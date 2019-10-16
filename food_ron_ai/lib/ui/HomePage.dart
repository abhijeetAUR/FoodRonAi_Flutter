import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageDataBloc _imageDataBloc = ImageDataBloc();

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
            padding: EdgeInsets.all(10),
              child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              onPressed: () {},
              icon: Icon(Icons.camera),
              label: Text("${Globals.cameraTxt}"),
            ),
          ))
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
                      onTap: () {},
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
