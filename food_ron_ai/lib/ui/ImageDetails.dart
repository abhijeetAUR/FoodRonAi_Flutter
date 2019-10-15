import 'package:flutter/material.dart';

import '../Global.dart';


class ImageDetails extends StatefulWidget {
  @override
  _ImageDetailsState createState() => _ImageDetailsState();
}

class _ImageDetailsState extends State<ImageDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topAppBar,
      body: DetailView(),
    );
  }
}

class DetailView extends StatelessWidget {
  String get imageName => null;

  String get imageUrl => null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(flex: 1,
        child: Card(
          child:GridTile(
              footer: Container(
                color: Colors.black26,
                child: ListTile(
                  leading: Text( imageName, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white), ),
                ),
              ) ,
              child: Image.asset(imageUrl,fit: BoxFit.cover,),
            ),

        ),
        ),
      ],
      
    );
  }
}