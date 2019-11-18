import 'dart:convert';
import 'dart:core';

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
  SerchedItemMetaData metadata;

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
      metadata: SerchedItemMetaData.fromJson(json['metadata']),
    );
  }
}

class SerchedItemMetaData {
  String food;
  String calorievalue;
  String protain;
  String fat;
  String carbs;
  String fiber;
  String weight;
  String servingsize;
  String serveunit;

  SerchedItemMetaData(
      {this.food,
      this.calorievalue,
      this.protain,
      this.fat,
      this.carbs,
      this.fiber,
      this.weight,
      this.servingsize,
      this.serveunit});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['food'] = food;
    map['calorievalue'] = calorievalue;
    map['protain'] = protain;
    map['fat'] = fat;
    map['carbs'] = carbs;
    map['fiber'] = fiber;
    map['weight'] = weight;
    map['servingsize'] = servingsize;
    map['serveunit'] = serveunit;
    return map;
  }

  factory SerchedItemMetaData.fromJson(Map<String, dynamic> json) {
    return SerchedItemMetaData(
      food: json['food'],
      calorievalue: json['Calorievalue'],
      protain: json['Protein'],
      fat: json['Fat'],
      carbs: json['Carbs'],
      fiber: json['Fiber'],
      weight: json['Weight'],
      servingsize: json['ServingSize'],
      serveunit: json['ServeUnit'],
    );
  }
}
