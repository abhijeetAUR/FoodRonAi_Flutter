import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_ron_ai/Global.dart' as globals;
import 'package:food_ron_ai/bloc/ImageDataBloc.dart';
import 'package:food_ron_ai/stracture/ImageMetaData.dart';

class HomeScreen extends StatefulWidget {
  final appName = "Foodron.ai";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageDataBloc _imageDataBloc = ImageDataBloc();

  @override
  void dispose() {
    // TODO: implement dispose
    _imageDataBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topAppBar,
      body: FoodItems(),
    );
  }
}

class FoodItems extends StatefulWidget {
  @override
  _FoodItemsState createState() => _FoodItemsState();
}

class _FoodItemsState extends State<FoodItems> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

final topAppBar = AppBar(
  title: Center(
    child: Text("${globals.appName}"),
  ),
);
