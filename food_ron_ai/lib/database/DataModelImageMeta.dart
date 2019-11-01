import 'package:food_ron_ai/stracture/ImageMetaData.dart';

class DataModelImageMeta{
  int _id;
  int _indexno;
  String _foodname;
  double _weight;
  double _serve;
  double _cal;
  double _carb;
  double _fat;
  double _protin;
  double _fiber;
  double _suger;
  String _imgurl;

  DataModelImageMeta(this._id,this._indexno,this._foodname,this._weight,this._cal,this._carb,this._fat,this._fiber,this._protin,this._serve,this._suger,this._imgurl);

  int get id => _id;

  int get indexno => _indexno;

  String get foodname => _foodname;

  double get weight => _weight;

  double get cal => _cal;

  double get carb => _carb;

  double get fat => _fat;

  double get fiber => _fiber;

  double get protin => _protin;

  double get serve => _serve;

  double get suger => _suger;

  String get imgurl => _imgurl;

  set indexno(int newIndexno){
    this._indexno = newIndexno;
  }

  set foodname(String newFoodname){
    //validation check if any
    this._foodname = newFoodname;
  }
  
  set weight(double newWeight){
    this._weight = newWeight;
  }
  
  set cal(double newCal){
    this._cal = newCal;
  }
  
  set carb(double newCarb){
    this._carb = newCarb;
  }
  
  set fat(double newFat){
    this._fat = newFat;
  }
  
  set fiber(double newFiber){
    this._fiber = newFiber;
  }
  
  set protin(double newProtin){
    this._protin = newProtin;
  }
  
  set serve(double newServe){
    this._serve = newServe;
  }
  
  set suger(double newSuger){
    this._suger = newSuger;
  }
  
  set imgurl(String newImgurl){
    this._imgurl= newImgurl;
  }
//convert image meta object into map
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if(id != null){
      map['id'] = _id;
    }
    map['indexno'] = _indexno;
    map['foodname'] = _foodname;
    map['weight'] = _weight;
    map['serve'] = _serve;
    map['cal'] = _cal;
    map['carb'] = _carb;
    map['fat'] = _fat;
    map['protin'] = _protin;
    map['fiber'] = _fiber;
    map['suger'] = _suger;
    map['imgurl'] = _imgurl;

    return map;
  }

//extract imaget object from map object
  DataModelImageMeta.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._indexno = map['indexno'];
    this._foodname = map['foodname'];
    this._weight = map['weight'];
    this._serve = map['serve'];
    this._cal = map['cal'];
    this._carb = map['carb'];
    this._fat = map['fat'];
    this._protin = map['protin'];
    this._fiber = map['fiber'];
    this._suger = map['suger'];
    this._imgurl = map['imgurl'];

  }
  
}