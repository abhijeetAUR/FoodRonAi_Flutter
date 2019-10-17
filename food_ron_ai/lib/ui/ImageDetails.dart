import 'package:flutter/material.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/customwidgets/DetailCard.dart';
import '../Global.dart';


class ImageDetails extends StatefulWidget {
  @override
  _ImageDetailsState createState() => _ImageDetailsState();
}

class _ImageDetailsState extends State<ImageDetails> {
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
      appBar: topAppBar,
      body: DetailView(),
    );
  }
}

class DetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        Expanded(flex: 2,
        child: Card(
          child: Image.asset('images/pizza.jpg',
          fit: BoxFit.fill,
          ),
        ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.red,
            child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return DetailsOfImageCardWidget();
              
            }
            ),
          ),
        )
      ],
      
    );
  }
}