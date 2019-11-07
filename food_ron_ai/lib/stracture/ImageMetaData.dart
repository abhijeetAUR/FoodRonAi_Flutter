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
