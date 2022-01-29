import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_flutter_version/util/util.dart';

import '../painted_widgets/drawDot.dart';
import '../painted_widgets/drawFillingCircle.dart';

class Pomodoro extends StatefulWidget {
  const Pomodoro({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PomodoroState();
}

class PomodoroState extends State<Pomodoro> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
      ),
      body: ListView(
        children: [
          item(context,10000,5550),
          Divider(),
          item(context,100,90),
        ],
      ),
    );
  }
}

Widget item(BuildContext context, double periodMs, double currentMs) => Container(
      height: 60,
      color: Colors.amberAccent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomPaint(
            foregroundPainter: DotPainter(context: context),
          ),
           Text(
            displayTime(currentMs),
            style: TextStyle(fontSize: 20),//TODO AWESOME STYLE
          ),
          CustomPaint(
            foregroundPainter:
                FillingCircle(currentMs: currentMs, periodMs: periodMs, context: context),
          ),
        ],
      ),
    );




