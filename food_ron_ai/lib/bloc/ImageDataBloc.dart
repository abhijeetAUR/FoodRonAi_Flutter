import 'dart:async';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:sqflite/sqflite.dart';

class ImageDataBloc {
  List<ImageMetaData> _metaData = [];

  final _imageListStreamController = StreamController<List<ImageMetaData>>();
  final _imageServeIncrementStreamController =
      StreamController<ImageMetaData>();
  final _imageListUpdateStreamController =
      StreamController<List<ImageMetaData>>();

  Stream<List<ImageMetaData>> get imageListStream =>
      _imageListStreamController.stream;

  StreamSink<List<ImageMetaData>> get imageListSink =>
      _imageListStreamController.sink;

  StreamSink<ImageMetaData> get imageServeIncrement =>
      _imageServeIncrementStreamController.sink;
  StreamSink<List<ImageMetaData>> get imageServeDecrement =>
      _imageListUpdateStreamController.sink;

  ImageDataBloc() {
    _imageListStreamController.add(_metaData);

    _imageServeIncrementStreamController.stream.listen(_incrementServe);
    _imageListUpdateStreamController.stream.listen(passDataToImageList);
  }

  _incrementServe(ImageMetaData imageMetaData) {
    int changedServe = Globals.servecount;
    var item = _metaData
        .where((oneItem) => oneItem.id == imageMetaData.id)
        .toList()
        .first;
    var index = _metaData.indexOf(imageMetaData);
    imageMetaData.weight =
        ((item.weight / item.serve) * changedServe).truncate();
    imageMetaData.cal = ((item.cal / item.serve) * changedServe).truncate();
    imageMetaData.card = ((item.card / item.serve) * changedServe).truncate();
    imageMetaData.fat = ((item.fat / item.serve) * changedServe).truncate();
    imageMetaData.protin =
        ((item.protin / item.serve) * changedServe).truncate();
    imageMetaData.fiber = ((item.fiber / item.serve) * changedServe).truncate();
    imageMetaData.suger = ((item.suger / item.serve) * changedServe).truncate();
    imageMetaData.serve = changedServe;
    _metaData[index] = imageMetaData;
    imageListSink.add(_metaData);
    Globals.servecount = 0;
  }

  passDataToImageList(List<ImageMetaData> updateImageList) {
    _imageListStreamController.sink.add(updateImageList);
    _metaData.clear();
    _metaData.addAll(updateImageList);
  }

  void dispose() {
    _imageListStreamController.close();
    _imageListUpdateStreamController.close();
    _imageServeIncrementStreamController.close();
  }
}
