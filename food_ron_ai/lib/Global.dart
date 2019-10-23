library global_values.globals;

import 'dart:io';

import 'package:flutter/material.dart';

final appName = "Foodron.ai";
final img_url = "api.foodron.ai/img-url";
final serve = "Serve";
double servecount = 1;
final weight = "Weight";
final calorie = "Calorie";
final carbohydrates = "Carb's";
final fiber = "Fiber";
final fat = "Fat";
final protein = "Protein";
final sugar = "Suger";
final imguploadurl = "http://api.foodron.ai/v1.0/uploadimg";
final inf_img_url = "api.foodron.ai/inf-img-url";
final cameraTxt = "camera";
var apiResponse ;
var apiData;
var apiImgUrl;
var apiitems;
var apiitemclass;
var apiitemCount;
final topAppBar = AppBar(
  title: Center(
    child: Text("$appName"),
  ),
);