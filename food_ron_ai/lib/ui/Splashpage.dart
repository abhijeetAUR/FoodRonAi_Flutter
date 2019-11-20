import 'package:flutter/material.dart';
import 'dart:async';
import 'package:food_ron_ai/ui/HomePage.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
// THIS FUNCTION WILL NAVIGATE FROM SPLASH SCREEN TO HOME SCREEN.    // USING NAVIGATOR CLASS.

  void navigationToNextPage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

  startSplashScreenTimer() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationToNextPage);
  }

  @override
  void initState() {
    super.initState();
    startSplashScreenTimer();
  }

  @override
  Widget build(BuildContext context) {
    // full screen image for splash screen.
    return Scaffold(
        body: SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: new Image.asset('images/splashgraphic.png', fit: BoxFit.cover))
    ));
  }
}
