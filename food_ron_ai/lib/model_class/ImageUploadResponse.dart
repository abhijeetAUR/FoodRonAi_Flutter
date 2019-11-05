import 'dart:core';

class ImageUploadResponse {
  String img_url;
  String inf_img_url;
  int item_count;
  List<ImageUploadMetaItems> items;

  ImageUploadResponse({this.img_url, this.inf_img_url, this.item_count})
      : items = List<ImageUploadMetaItems>();

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['img_url'] = img_url;
    map['inf_img_url'] = inf_img_url;
    map['item_count'] = item_count;
    map['items'] = items;

    return map;
  }
}

class ImageUploadMetaItems {
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

  factory ImageUploadMetaItems.fromJson(Map<String, dynamic> json) {
    return ImageUploadMetaItems(
      name: json['name'].toString() + ",",
      weight: json['weight'] + ",",
      serve: json['serve'] + ",",
      calorie: json['calorie'] + ",",
      carbohydrates: json['carbohydrates'] + ",",
      fat: json['fat'] + ",",
      protein: json['protein'] + ",",
      fiber: json['fiber'] + ",",
      sugar: json['sugar'] + ",",
    );
  }
}
