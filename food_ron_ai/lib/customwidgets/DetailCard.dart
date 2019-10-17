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
      height: 350,
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
                _serve = (val * 10).round();
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
    return Container(
        child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            new Col1Info(),
            new Col2Info(),
          ],
        ),

        Row(
          children: <Widget>[
            Col3Info(),
          ],
        )
      ],
    ));
  }
}

class Col3Info extends StatefulWidget {
  @override
  _Col3InfoState createState() => _Col3InfoState();
}

class _Col3InfoState extends State<Col3Info> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: MediaQuery.of(context).size.width,
      padding: new EdgeInsets.only(left: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${Globals.protein} :\t \n',
            style: TextStyle(fontSize: 20.0),
          ),
        ],
      ),
    );
  }
}

class Col2Info extends StatelessWidget {
  const Col2Info({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Colors.blue,
        width: MediaQuery.of(context).size.width / 2,
        padding: new EdgeInsets.only(left: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 30.0),
            Text(
              '\n${Globals.fat} :\t \n',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(width: 30.0),
            Text(
              '${Globals.fiber} :\t \n',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(width: 30.0),
            Text(
              '${Globals.sugar} :\t \n',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ));
  }
}

class Col1Info extends StatelessWidget {
  const Col1Info({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Colors.blue,
        width: MediaQuery.of(context).size.width / 2,
        padding: new EdgeInsets.only(left: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 30.0),
            Text(
              '\n${Globals.weight} :\t \n',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            SizedBox(width: 30.0),
            Text(
              '${Globals.calorie} :\t \n',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(width: 30.0),
            Text(
              '${Globals.carbohydrates} :\t \n',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ));
  }
}
