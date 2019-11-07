import 'dart:core';

class ImageUploadResponse {
  int id;
  int itemMetaId;
  String img_url;
  String inf_img_url;
  int item_count;
  List<ImageUploadMetaItems> items;

  ImageUploadResponse(
      {this.itemMetaId, this.img_url, this.inf_img_url, this.item_count})
      : items = List<ImageUploadMetaItems>();

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['img_url'] = img_url;
    map['inf_img_url'] = inf_img_url;
    map['itemMetaId'] = itemMetaId;
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
  ImageUploadMetaItems({
    this.itemMetaId,
    this.name,
    this.weight,
    this.serve,
    this.calorie,
    this.carbohydrates,
    this.fat,
    this.protein,
    this.fiber,
    this.sugar,
  });

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
    );
  }
}
