import 'package:flutter/material.dart';
import 'package:food_ron_ai/Global.dart' as Globals;

import 'WaveSlider.dart';

class DetailsOfImageCardWidget extends StatefulWidget {
  @override
  _DetailsOfImageCardWidgetState createState() =>
      _DetailsOfImageCardWidgetState();
}

class _DetailsOfImageCardWidgetState extends State<DetailsOfImageCardWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 250,
      color: Colors.green,
      child: Column(
        children: <Widget>[
          new ServeWidget(),
          new MetaInformationWidget(),
        ],
      ),
    );
  }
}

class ServeWidget extends StatefulWidget {
  @override
  _ServeWidgetState createState() => _ServeWidgetState();
}

class _ServeWidgetState extends State<ServeWidget> {
  int _serve = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(width: 20.0),
          WaveSlider(
            onChanged: (double val) {
              setState(() {
                _serve = (val * 5).round();
              });
            },
          ),
          SizedBox(width: 30.0),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  Text(
                    '\t\t${Globals.serve} :\t',
                    style: TextStyle(fontSize: 25.0),
                  ),
                  Text(
                    _serve.toString(),
                    style: TextStyle(fontSize: 25.0),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class MetaInformationWidget extends StatefulWidget {
  @override
  _MetaInformationWidgetState createState() => _MetaInformationWidgetState();
}

class _MetaInformationWidgetState extends State<MetaInformationWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
