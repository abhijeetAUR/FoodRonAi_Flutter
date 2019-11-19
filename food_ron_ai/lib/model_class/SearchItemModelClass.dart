import 'dart:core';

class SearchItemResponse {
  List<ArraySearchItems> items;
  int itemCount;
  SearchItemResponse({this.itemCount, this.items});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['items'] = items;
    return map;
  }

  factory SearchItemResponse.fromJson(Map<String, dynamic> json) {
    return SearchItemResponse(
      itemCount: json['count'],
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
  String calorieValue;
  String protein;
  String fat;
  String carbs;
  String fiber;
  String weight;
  String servingSize;
  String serveUnit;
  String sugar;
  int itemMetaId;

  SerchedItemMetaData(
      {this.food,
      this.calorieValue,
      this.protein,
      this.fat,
      this.carbs,
      this.fiber,
      this.weight,
      this.servingSize,
      this.serveUnit,
      this.itemMetaId,
      this.sugar});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['name'] = food;
    map['calorie'] = calorieValue;
    map['protein'] = protein;
    map['fat'] = fat;
    map['carbohydrates'] = carbs;
    map['fiber'] = fiber;
    map['weight'] = weight;
    map['serveSize'] = servingSize;
    map['serveUnit'] = serveUnit;
    map['itemMetaId'] = itemMetaId;
    map['sugar'] = sugar;
    return map;
  }

  factory SerchedItemMetaData.fromJson(Map<String, dynamic> json) {
    return SerchedItemMetaData(
      food: json['food'],
      calorieValue: json['Calorievalue'],
      protein: json['Protein'],
      fat: json['Fat'],
      carbs: json['Carbs'],
      fiber: json['Fiber'],
      weight: json['Weight'],
      servingSize: json['ServingSize'],
      serveUnit: json['ServeUnit'],
      sugar: json['Sugar'],
    );
  }
}
