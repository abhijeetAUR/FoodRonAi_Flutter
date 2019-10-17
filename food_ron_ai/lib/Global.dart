library global_values.globals;

import 'dart:io';

import 'package:flutter/material.dart';

final appName = "Foodron.ai";
final img_url = "api.foodron.ai/img-url";
File _image;
final serve = "Serve";
final weight = "Weight";
final calorie = "Calorie";
final carbohydrates = "Carbohydrates";
final fiber = "Fiber";
final fat = "Fat";
final protein = "Protein";
final sugar = "Suger";

final inf_img_url = "api.foodron.ai/inf-img-url";
final cameraTxt = "camera";
final topAppBar = AppBar(
  title: Center(
    child: Text("$appName"),
  ),
);