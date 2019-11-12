import 'dart:async';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:food_ron_ai/Global.dart' as Globals;

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
    double changedServe = Globals.servecount;
    var item = _metaData
        .where((oneItem) => oneItem.id == imageMetaData.id)
        .toList()
        .first;
    var index = _metaData.indexOf(imageMetaData);
    imageMetaData.weight =
        ((item.weight / item.serve) * changedServe);
    imageMetaData.cal = ((item.cal / item.serve) * changedServe);
    imageMetaData.card = ((item.card / item.serve) * changedServe);
    imageMetaData.fat = ((item.fat / item.serve) * changedServe);
    imageMetaData.protin =
        ((item.protin / item.serve) * changedServe);
    imageMetaData.fiber = ((item.fiber / item.serve) * changedServe);
    imageMetaData.suger = ((item.suger / item.serve) * changedServe);
    imageMetaData.serve = changedServe.truncateToDouble();
    _metaData[index] = imageMetaData;
    Globals.metaData.clear();
    Globals.metaData.addAll(_metaData);
    Globals.servecount = 0;
    imageListSink.add(_metaData);
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

  getMetaData() {
    return _metaData;
  }
}
