import 'package:flutter/material.dart' show BuildContext, Colors, MaterialApp, State, StatefulWidget, ThemeData, Widget, runApp;
import 'package:food_ron_ai/ui/SplashScreen.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  theme: 
  ThemeData(primaryColor: Colors.orangeAccent, accentColor: Colors.orangeAccent),
  debugShowCheckedModeBanner: false,
  home: SplashScreen(),
  );
  }
}

