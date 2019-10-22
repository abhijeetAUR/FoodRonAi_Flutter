import 'dart:async';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:food_ron_ai/Global.dart' as Globals;


class ImageDataBloc{

  List<ImageMetaData> _imagelist = [
    ImageMetaData(1,"Pizza",10, 160, 23, 6.6, 4.3, 4.9, 1,6),
    ImageMetaData(2,"Roti",14,116, 21, 2.4, 2.9, 4.6, 5,6)
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
  double changedServe = Globals.servecount;
  _imagelist[imageMetaData.id - 1].serve = changedServe;

  imageListSink.add(_imagelist);

  if(Globals.servecount > 1)
  {
    _imagelist[imageMetaData.id - 1].card = _imagelist[imageMetaData.id - 1].card * changedServe;
    _imagelist[imageMetaData.id - 1].fat = _imagelist[imageMetaData.id - 1].fat * changedServe;
    _imagelist[imageMetaData.id - 1].cal = _imagelist[imageMetaData.id - 1].cal * changedServe;
    _imagelist[imageMetaData.id - 1].fiber = _imagelist[imageMetaData.id - 1].fiber * changedServe;
    _imagelist[imageMetaData.id - 1].protin = _imagelist[imageMetaData.id - 1].protin * changedServe;
    _imagelist[imageMetaData.id - 1].suger = _imagelist[imageMetaData.id - 1].suger * changedServe;
    _imagelist[imageMetaData.id - 1].weight = _imagelist[imageMetaData.id - 1].weight * changedServe;
  }
  //TODO: increment serve count here
}

_decrementServe(ImageMetaData imageMetaData){
  
}

void dispose(){
  _imageListStreamController.close();
  _imageServeDecrementStreamController.close();
  _imageServeIncrementStreamController.close();
}

}

