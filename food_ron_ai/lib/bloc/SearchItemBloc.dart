import 'dart:async';
import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';

class SearchItemBloc {
  List<ImageUploadMetaItems> _lstSerchedItemMetaData = [];

  final _imageSearchListStreamController = StreamController<List<ImageUploadMetaItems>>();
  final _imageSearchOnvalueChangeStreamController = StreamController<List<ImageUploadMetaItems>>();

  Stream<List<ImageUploadMetaItems>> get searchItemStream => _imageSearchListStreamController.stream;

  StreamSink<List<ImageUploadMetaItems>> get imageListSink => _imageSearchOnvalueChangeStreamController.sink;

  SearchItemBloc() {
    _imageSearchListStreamController.add(_lstSerchedItemMetaData);

    _imageSearchOnvalueChangeStreamController.stream.listen(changeListOnBlocFromDB);
  }

  changeListOnBlocFromDB(List<ImageUploadMetaItems> updatedSearchItemList){
    _imageSearchListStreamController.sink.add(updatedSearchItemList);
    _lstSerchedItemMetaData.clear();
    _lstSerchedItemMetaData.addAll(updatedSearchItemList);
  }

  void dispose() {
    _imageSearchListStreamController.close();
    _imageSearchOnvalueChangeStreamController.close();
  }
 
}
