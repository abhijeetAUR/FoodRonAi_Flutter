import 'package:flutter/material.dart';
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/customwidgets/CardDetailsView.dart';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';
import '../Global.dart';

class ImageDetails extends StatefulWidget {
  final ImageUploadResponse imageUploadResponse;
  ImageDetails({@required this.imageUploadResponse});
  @override
  _ImageDetailsState createState() =>
      _ImageDetailsState(imageUploadResponse: imageUploadResponse);
}

class _ImageDetailsState extends State<ImageDetails> {
  final ImageDataBloc _imageDataBloc = ImageDataBloc();
  final ImageUploadResponse imageUploadResponse;
  _ImageDetailsState({@required this.imageUploadResponse});
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
      body: DetailView(
        imageUploadResponse: imageUploadResponse,
      ),
    );
  }
}

class DetailView extends StatelessWidget {
  final ImageUploadResponse imageUploadResponse;
  DetailView({@required this.imageUploadResponse});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Card(
            child: Image.network(
              imageUploadResponse.img_url,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: CardDetailsView(imageUploadResponse: imageUploadResponse),
          ),
        )
      ],
    );
  }
}
