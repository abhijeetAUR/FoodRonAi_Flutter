import 'dart:ffi';

class ImageMetaData{
  int _id;
  String _foodname;
  double _weight;
  double _serve;
  double _cal;
  double _card;
  double _fat;
  double _protin;
  double _fiber;
  double _suger;

  ImageMetaData(this._id,this._foodname,this._weight,this._cal,this._card,this._fat,this._fiber,this._protin,this._serve,this._suger);

  //setters
  set id(int id){
    this._id=id;
  }
  set foodname(String foodname){
    this._foodname=foodname;
  }

  set weight(double weight){
    this._weight=weight;
  }
  
  set serve(double serve){
    this._serve=serve;
  }

  set fat(double fat){
    this._fat=fat;
  }

  set protin(double protin){
    this._protin=protin;
  }

  set fiber(double fiber){
    this._fiber=fiber;
  }

  set cal(double cal){
    this._cal=cal;
  }

  set card(double card){
    this._card=card;
  }
  set suger(double suger){
    this._suger=suger;
  }

  //getters
  int get id => this._id;

  String get foodname => this._foodname;

  double get weight => this._weight;

  double get cal => this._cal;

  double get card => this._card;

  double get protin => this._protin;

  double get fiber => this._fiber;

  double get fat => this._fat;

  double get serve => this._serve;
     
  double get suger => this._suger;
}