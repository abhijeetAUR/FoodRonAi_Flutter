class ImageMetaData {
  int id;
  int itemMetaId;
  String foodname;
  int weight;
  int serve;
  int cal;
  int card;
  int fat;
  int protin;
  int fiber;
  int suger;

  ImageMetaData(
      {this.id,
      this.itemMetaId,
      this.foodname,
      this.serve,
      this.weight,
      this.cal,
      this.card,
      this.fiber,
      this.fat,
      this.protin,
      this.suger});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['itemMetaId'] = itemMetaId;
    map['name'] = foodname;
    map['serve'] = serve;
    map['weight'] = weight;
    map['calorie'] = cal;
    map['carbohydrates'] = card;
    map['fiber'] = fiber;
    map['fat'] = fat;
    map['protein'] = protin;
    map['sugar'] = suger;
    return map;
  }

  factory ImageMetaData.fromJson(Map<String, dynamic> item) {
    return ImageMetaData(
        id: item["id"],
        itemMetaId: item["itemMetaId"],
        foodname: item["name"],
        serve: item["serve"],
        weight: item["weight"],
        cal: item["calorie"],
        card: item["carbohydrates"],
        fiber: item["fiber"],
        fat: item["fat"],
        protin: item["protein"],
        suger: item["sugar"]);
  }
}
