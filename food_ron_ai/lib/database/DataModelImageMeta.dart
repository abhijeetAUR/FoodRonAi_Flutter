import 'dart:core';

class ImgItemDataMapper {
  String name;
  double serve;
  double weight;
  double calories;
  double carbohydrates;
  double fiber;
  double fat;
  double protin;
  double suger;
}

//---------------------------------
class DataModelImageMeta {
  int _id;
  String _imgUrl;
  String _infImgUrl;
  List<String> _itemClass;
  List<ImgItemDataMapper> _items;
  
  DataModelImageMeta(
      // this._id,
      this._imgUrl,
      this._infImgUrl,
      this._itemClass,
      this._items
      );

  int get id => _id;

  String get imgurl => _imgUrl;

  String get infimgurl => _infImgUrl;

  List<String> get itemclass => _itemClass;

  List<ImgItemDataMapper> get items => _items;

  set imgurl(String newImgUrl){
    this._imgUrl = newImgUrl;
  }

  set infimgurl(String newImfImgUrl){
    this._infImgUrl = newImfImgUrl;
  }

  set itemclass(List<String> newItemClass){
    this._itemClass = newItemClass;
  }

  set items(List<ImgItemDataMapper> newItems){
    this._items = newItems;
  } 

//convert image meta object into map
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['imgurl'] = _imgUrl;
    map['infimgurl'] = _infImgUrl;
    map['itemclass'] = _itemClass;
    map['items'] = _items;

    return map;
  }

//extract imaget object from map object
  DataModelImageMeta.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._imgUrl = map['imgurl'];
    this._infImgUrl = map['infimgurl'];
    this._itemClass = map['itemclass'];
    this._items = map['items'];
  }
}