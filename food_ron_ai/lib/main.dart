import 'package:flutter/material.dart';
import 'package:food_ron_ai/ui/Splashpage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'foodron.ai',
      theme: new ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.green,
        hintColor: Colors.white,
        inputDecorationTheme: new InputDecorationTheme(
          labelStyle: new TextStyle(color: Colors.black),
        ),
      ),
      home: new SplashPage(),
    );
  }
}
