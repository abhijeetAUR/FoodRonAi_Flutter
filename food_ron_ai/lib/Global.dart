library global_values.globals;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';
import 'bloc/ImageDataBloc.dart';

final appName = "Foodron.ai";
final serve = "Serve";
int servecount ;
int counter = 1;
final weight = "Weight";
final calorie = "Calorie";
final carbohydrates = "Carb's";
final fiber = "Fiber";
final fat = "Fat";
final protein = "Protein";
final sugar = "Suger";
final imguploadurl = "http://api.foodron.ai/v1.0/uploadimg";
final cameraTxt = "camera";
List<ImageMetaData> changedImageMetaData = [ImageMetaData(0, 'no image',0,0 , 0, 0, 0, 0, 0, 0)] ;
var apiResponse ;
var apiData ;
var apiImgUrl;
var apiitems;
var apiitemclass;
var apiitemCount;
final topAppBar = AppBar(
  title: Center(
    child: Text("$appName"),
  ),
);