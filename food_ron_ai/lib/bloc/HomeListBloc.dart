import 'dart:async';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';

class HomeListBloc {
  final _imageListStreamController =
      StreamController<List<ImageUploadResponse>>();

  final _todayMetaData = StreamController<List<ImageUploadMetaItems>>();

  Stream<List<ImageUploadResponse>> get imageListStream =>
      _imageListStreamController.stream;

  StreamSink<List<ImageUploadResponse>> get imageListSink =>
      _imageListStreamController.sink;

  Stream<List<ImageUploadMetaItems>> get todaysMetaStream =>
      _todayMetaData.stream;
  StreamSink<List<ImageUploadMetaItems>> get todaysMetaSink =>
      _todayMetaData.sink;

  sinkTodaysMeta(List<ImageUploadMetaItems> updateHomelist) {
    todaysMetaSink.add(updateHomelist);
  }

  updateHomeList(List<ImageUploadResponse> updateHomelist) {
    imageListSink.add(updateHomelist);
  }

  void dispose() {
    _imageListStreamController.close();
    _todayMetaData.close();
  }
}
