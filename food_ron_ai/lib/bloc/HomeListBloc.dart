import 'dart:async';
import 'package:food_ron_ai/Global.dart' as Globals;
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';

class HomeListBloc {
  List<ImageUploadResponse> homeImageList = [];

  List<ImageUploadResponse> homeImageListtemp = [];

  final _imageListStreamController =
      StreamController<List<ImageUploadResponse>>();
  final _imageServeChangeStreamController =
      StreamController<ImageUploadResponse>();
  final _imageHomeListUpdateController =
      StreamController<List<ImageUploadResponse>>();

  Stream<List<ImageUploadResponse>> get imageListStream =>
      _imageListStreamController.stream;

  StreamSink<List<ImageUploadResponse>> get imageListSink =>
      _imageListStreamController.sink;

  StreamSink<ImageUploadResponse> get imageServeChange =>
      _imageServeChangeStreamController.sink;

  StreamSink<List<ImageUploadResponse>> get imageUpdateHomeList =>
      _imageHomeListUpdateController.sink;

  HomeListBloc() {
    _imageListStreamController.add(homeImageList);

    _imageServeChangeStreamController.stream.listen(_changeServe);
    _imageHomeListUpdateController.stream.listen(updateHomeList);
  }

  updateHomeList(List<ImageUploadResponse> updateHomelist) {
    _imageListStreamController.sink.add(updateHomelist);
  }

  _changeServe(ImageUploadResponse imageUploadResponse) {
    int changedServe = Globals.servecount;
  }

  void dispose() {
    _imageListStreamController.close();

    _imageServeChangeStreamController.close();

    _imageHomeListUpdateController.close();
  }
}
