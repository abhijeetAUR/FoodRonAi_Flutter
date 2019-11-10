library global_values.globals;

import 'package:flutter/material.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';

final appName = "Foodron.ai";
final serve = "Serve";
int servecount;
int counter = 1;
final weight = "Weight";
final calorie = "Calorie";
final carbohydrates = "Carbohydrate";
final fiber = "Fiber";
final fat = "Fat";
final protein = "Protein";
final sugar = "Suger";
final imguploadurl = "http://api.foodron.ai/v1.0/uploadimg";
final cameraTxt = "camera";
List<ImageMetaData> changedImageMetaData = [];
var apiResponse;
var apiData;
var apiImgUrl;
var apiitems;
var apiitemclass;
var apiitemCount;
List<ImageMetaData> metaData = [];
final topAppBar = AppBar(
  title: Center(
    child: Text("$appName"),
  ),
);
