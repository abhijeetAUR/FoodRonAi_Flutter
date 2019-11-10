import 'dart:core';

class ImageUploadResponse {
  int id;
  int itemMetaId;
  String imgUrl;
  String infImgUrl;
  int itemCount;
  String datetime;
  List<ImageUploadMetaItems> items;

  ImageUploadResponse(
      {this.itemMetaId, this.imgUrl, this.infImgUrl, this.itemCount})
      : items = List<ImageUploadMetaItems>();

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['img_url'] = imgUrl;
    map['inf_img_url'] = infImgUrl;
    map['itemMetaId'] = itemMetaId;
    map['datetime'] = datetime;
    return map;
  }
}

class ImageUploadMetaItems {
  int id;
  int itemMetaId;
  String name;
  int weight;
  int serve;
  int calorie;
  int carbohydrates;
  int fat;
  int protein;
  int fiber;
  int sugar;
  String datetime;

  ImageUploadMetaItems(
      {this.itemMetaId,
      this.name,
      this.weight,
      this.serve,
      this.calorie,
      this.carbohydrates,
      this.fat,
      this.protein,
      this.fiber,
      this.sugar,
      this.datetime});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['itemMetaId'] = itemMetaId;
    map['name'] = name;
    map['weight'] = weight;
    map['serve'] = serve;
    map['calorie'] = calorie;
    map['carbohydrates'] = carbohydrates;
    map['fat'] = fat;
    map['protein'] = protein;
    map['fiber'] = fiber;
    map['sugar'] = sugar;
    map['datetime'] = datetime;
    return map;
  }

  factory ImageUploadMetaItems.fromJson(Map<String, dynamic> json) {
    return ImageUploadMetaItems(
        itemMetaId: json['itemMetaId'],
        name: json['name'].toString(),
        weight: json['weight'],
        serve: json['serve'],
        calorie: json['calorie'],
        carbohydrates: json['carbohydrates'],
        fat: json['fat'],
        protein: json['protein'],
        fiber: json['fiber'],
        sugar: json['sugar'],
        datetime: DateTime.now().toString().substring(0, 10));
  }
}
