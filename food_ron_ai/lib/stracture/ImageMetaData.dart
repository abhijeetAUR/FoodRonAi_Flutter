import 'dart:ffi';

class ImageMetaData{
  int _id;
  String _foodname;
  int _weight;
  int _serve;
  int _cal;
  int _card;
  int _fat;
  int _protin;
  int _fiber;
  int _suger;
  String _imgurl;

  ImageMetaData(this._id,this._foodname,this._weight,this._cal,this._card,this._fat,this._fiber,this._protin,this._serve,this._suger,this._imgurl);

  //setters
  set id(int id){
    this._id=id;
  }
  set foodname(String foodname){
    this._foodname=foodname;
  }

  set weight(int weight){
    this._weight=weight;
  }
  
  set serve(int serve){
    this._serve=serve;
  }

  set fat(int fat){
    this._fat=fat;
  }

  set protin(int protin){
    this._protin=protin;
  }

  set fiber(int fiber){
    this._fiber=fiber;
  }

  set cal(int cal){
    this._cal=cal;
  }

  set card(int card){
    this._card=card;
  }
  set suger(int suger){
    this._suger=suger;
  }
  set imgurl(String imgurl){
    this._imgurl=imgurl;
  }


  //getters
  int get id => this._id;

  String get foodname => this._foodname;

  int get weight => this._weight;

  int get cal => this._cal;

  int get card => this._card;

  int get protin => this._protin;

  int get fiber => this._fiber;

  int get fat => this._fat;

  int get serve => this._serve;
     
  int get suger => this._suger;

  String get imgurl => this._imgurl;
}