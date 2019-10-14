import 'dart:ffi';

class ImageMetaData{

  String _foodname;
  double _serve;
  double _cal;
  double _card;
  double _fat;
  double _protin;
  double _fiber;

  ImageMetaData(this._foodname,this._cal,this._card,this._fat,this._fiber,this._protin,this._serve);

  //setters

  set foodname(String foodname){
    this._foodname=foodname;
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

  //getters

  String get foodname => this._foodname;

  double get cal => this._cal;

  double get card => this._card;

  double get protin => this._protin;

  double get fiber => this._fiber;

  double get fat => this._fat;

  double get serve => this._serve;
}