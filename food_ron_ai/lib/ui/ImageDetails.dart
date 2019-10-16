import 'package:flutter/material.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
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
          fit: BoxFit.cover,
          ),
        ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.red,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemCount: 2,
            itemBuilder: (BuildContext context, int index) {
              
            }
            ),
          ),
        )
      ],
      
    );
  }
}