import 'dart:async';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:sqflite/sqflite.dart';

class ImageDataBloc{
  
  List<ImageMetaData> _imagelist = [
    ImageMetaData(1,"daal",12, 80, 15, 7, 7, 19, 1,7,"images/pizza.jpg"),
    ImageMetaData(2,"rice",12, 80, 15, 7, 7, 19, 1,7,"images/pizza.jpg")
  ];
   List<ImageMetaData> _imagelist2 = [
    ImageMetaData(1,"daal",12, 80, 15, 7, 7, 19, 1,7,"images/pizza.jpg"),
    ImageMetaData(2,"rice",12, 80, 15, 7, 7, 19, 1,7,"images/pizza.jpg")
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
  int changedServe = Globals.servecount;

  if(Globals.servecount >= 1 && Globals.servecount <= 10)
  {
    _imagelist[imageMetaData.id - 1].card = _imagelist2[imageMetaData.id - 1].card * changedServe;
    _imagelist[imageMetaData.id - 1].fat = _imagelist2[imageMetaData.id - 1].fat * changedServe;
    _imagelist[imageMetaData.id - 1].cal = _imagelist2[imageMetaData.id - 1].cal * changedServe;
    _imagelist[imageMetaData.id - 1].fiber = _imagelist2[imageMetaData.id - 1].fiber * changedServe;
    _imagelist[imageMetaData.id - 1].protin = _imagelist2[imageMetaData.id - 1].protin * changedServe;
    _imagelist[imageMetaData.id - 1].suger = _imagelist2[imageMetaData.id - 1].suger * changedServe;
    _imagelist[imageMetaData.id - 1].weight = _imagelist2[imageMetaData.id - 1].weight * changedServe;
  }
  _imagelist[imageMetaData.id - 1].serve = changedServe;
  Globals.servecount=0;
  imageListSink.add(_imagelist);
}

_decrementServe(ImageMetaData imageMetaData){
  
}

void dispose(){
  _imageListStreamController.close();
  _imageServeDecrementStreamController.close();
  _imageServeIncrementStreamController.close();
}

}

