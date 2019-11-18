import 'dart:convert';
import 'dart:core';

import 'package:food_ron_ai/model_class/ImageUploadResponse.dart';

class SearchItemResponse {
  List<ArraySearchItems> items;

  SearchItemResponse({this.items});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['items'] = items;
    return map;
  }

  factory SearchItemResponse.fromJson(Map<String, dynamic> json) {
    return SearchItemResponse(
      items: (json['items'] as List)
          .map((oneItem) => ArraySearchItems.fromJson(oneItem))
          .toList(),
    );
  }
}

class ArraySearchItems {
  String foodname;
  ImageUploadMetaItems metadata;

  ArraySearchItems({this.foodname, this.metadata});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['foodname'] = foodname;
    map['metadata'] = metadata;
    return map;
  }

  factory ArraySearchItems.fromJson(Map<String, dynamic> json) {
    return ArraySearchItems(
      foodname: json['foodname'],
      metadata: ImageUploadMetaItems.fromJson(json['metadata']),
    );
  }
}

class SerchedItemMetaData {
  String food;
  String calorieValue;
  String protain;
  String fat;
  String carbs;
  String fiber;
  String weight;
  String servingSize;
  String serveUnit;

  SerchedItemMetaData(
      {this.food,
      this.calorieValue,
      this.protain,
      this.fat,
      this.carbs,
      this.fiber,
      this.weight,
      this.servingSize,
      this.serveUnit});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['food'] = food;
    map['calorieValue'] = calorieValue;
    map['protain'] = protain;
    map['fat'] = fat;
    map['carbs'] = carbs;
    map['fiber'] = fiber;
    map['weight'] = weight;
    map['servingSize'] = servingSize;
    map['serveUnit'] = serveUnit;
    return map;
  }

  factory SerchedItemMetaData.fromJson(Map<String, dynamic> json) {
    return SerchedItemMetaData(
      food: json['food'],
      calorieValue: json['Calorievalue'],
      protain: json['Protein'],
      fat: json['Fat'],
      carbs: json['Carbs'],
      fiber: json['Fiber'],
      weight: json['Weight'],
      servingSize: json['ServingSize'],
      serveUnit: json['ServeUnit'],
    );
  }
}
