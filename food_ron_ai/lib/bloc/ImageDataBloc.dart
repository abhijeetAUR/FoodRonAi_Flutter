import 'dart:async';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:sqflite/sqflite.dart';

class ImageDataBloc {
  List<ImageMetaData> _imagelist = [];
  //Globals.changedImageMetaData;

  List<ImageMetaData> _imagelist2 = [];

  //Globals.changedImageMetaData;

  final _imageListStreamController = StreamController<List<ImageMetaData>>();
  final _imageServeIncrementStreamController =
      StreamController<ImageMetaData>();
  final _imageServeDecrementStreamController =
      StreamController<List<ImageMetaData>>();

  Stream<List<ImageMetaData>> get imageListStream =>
      _imageListStreamController.stream;

  StreamSink<List<ImageMetaData>> get imageListSink =>
      _imageListStreamController.sink;

  StreamSink<ImageMetaData> get imageServeIncrement =>
      _imageServeIncrementStreamController.sink;
  StreamSink<List<ImageMetaData>> get imageServeDecrement =>
      _imageServeDecrementStreamController.sink;

  ImageDataBloc() {
    _imageListStreamController.add(_imagelist);

    _imageServeIncrementStreamController.stream.listen(_incrementServe);
    _imageServeDecrementStreamController.stream.listen(passDataToImageList);
  }

  _incrementServe(ImageMetaData imageMetaData) {
    int changedServe = Globals.servecount;

    if (Globals.servecount >= 1 && Globals.servecount <= 10) {
      _imagelist[imageMetaData.id - 1000].card =
          _imagelist2[imageMetaData.id - 1000].card * changedServe;
      _imagelist[imageMetaData.id - 1000].fat =
          _imagelist2[imageMetaData.id - 1000].fat * changedServe;
      _imagelist[imageMetaData.id - 1000].cal =
          _imagelist2[imageMetaData.id - 1000].cal * changedServe;
      _imagelist[imageMetaData.id - 1000].fiber =
          _imagelist2[imageMetaData.id - 1000].fiber * changedServe;
      _imagelist[imageMetaData.id - 1000].protin =
          _imagelist2[imageMetaData.id - 1000].protin * changedServe;
      _imagelist[imageMetaData.id - 1000].suger =
          _imagelist2[imageMetaData.id - 1000].suger * changedServe;
      _imagelist[imageMetaData.id - 1000].weight =
          _imagelist2[imageMetaData.id - 1000].weight * changedServe;
    }
    _imagelist[imageMetaData.id - 1000].serve = changedServe;
    Globals.servecount = 0;
    imageListSink.add(_imagelist);
  }

  passDataToImageList(List<ImageMetaData> updateImageList) {
    _imageListStreamController.sink.add(updateImageList);
    _imageListStreamController.sink.add(updateImageList);
  }

  void dispose() {
    _imageListStreamController.close();
    _imageServeDecrementStreamController.close();
    _imageServeIncrementStreamController.close();
  }
}
