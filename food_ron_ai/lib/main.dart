import 'package:flutter/material.dart';
import 'package:food_ron_ai/splash_screen.dart';

void main() => runApp(new MaterialApp(
  theme: 
  ThemeData(primaryColor: Colors.redAccent, accentColor: Colors.yellowAccent),
  debugShowCheckedModeBanner: false,
  home: SplashScreen(),
),
);