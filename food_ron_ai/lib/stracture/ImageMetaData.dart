
class ImageMetaData{
  int id;
  String foodname;
  int weight;
  int serve;
  int cal;
  int card;
  int fat;
  int protin;
  int fiber;
  int suger;

  ImageMetaData(this.id,this.foodname,this.serve,this.weight,this.cal,this.card,this.fiber,this.fat,this.protin,this.suger);

  //setters
  set itemid(int id){
    this.id=id;
  }
  set itemfoodname(String foodname){
    this.foodname=foodname;
  }

  set itemweigh(int weight){
    this.weight=weight;
  }
  
  set itemserve(int serve){
    this.serve=serve;
  }

  set itemfat(int fat){
    this.fat=fat;
  }

  set itemprotin(int protin){
    this.protin=protin;
  }

  set itemfiber(int fiber){
    this.fiber=fiber;
  }

  set itemcal(int cal){
    this.cal=cal;
  }

  set itemcard(int card){
    this.card=card;
  }
  set itemsuger(int suger){
    this.suger=suger;
  }
 

  //getters
  int get itemid => this.id;

  String get itemfoodname => this.foodname;

  int get itemweigh => this.weight;

  int get itemcal => this.cal;

  int get itemcard => this.card;

  int get itemprotin => this.protin;

  int get itemfiber => this.fiber;

  int get itemfat => this.fat;

  int get itemserve => this.serve;
     
  int get itemsuger => this.suger;

}