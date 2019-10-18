import 'dart:async';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';


class ImageDataBloc{

  List<ImageMetaData> _imagelist = [
    ImageMetaData("Pizza", 160, 23, 6.6, 4.3, 4.9, 1,6),
    ImageMetaData("Roti", 116, 21, 2.4, 2.9, 4.6, 5,6)
  ];

  final _imageListStreamController = StreamController<List<ImageMetaData>>();

  final _imageServeIncrementStreamController = StreamController<ImageMetaData>();
  final _imageServeDecrementStreamController = StreamController<ImageMetaData>();

  Stream<List<ImageMetaData>> get imageListStream => _imageListStreamController.stream;

  StreamSink<List<ImageMetaData>> get imageListSink => _imageListStreamController.sink;

  StreamSink<ImageMetaData> get imageServeIncrement => _imageServeIncrementStreamController.sink;
  StreamSink<ImageMetaData> get imageServeDecrement => _imageServeDecrementStreamController.sink;

  ImageDataBloc(){
    _imageListStreamController.add(_imagelist);

    _imageServeIncrementStreamController.stream.listen(_incrementServe);
    _imageServeDecrementStreamController.stream.listen(_decrementServe);
  }

_incrementServe(ImageMetaData imageMetaData){
  double serve = imageMetaData.serve;
  //TODO: increment serve count here
}

_decrementServe(ImageMetaData imageMetaData){
  double serve = imageMetaData.serve;
}

void dispose(){
  _imageListStreamController.close();
  _imageServeDecrementStreamController.close();
  _imageServeIncrementStreamController.close();
}

}

