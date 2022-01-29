import 'package:flutter/material.dart';
import 'package:pomodoro_flutter_version/pages/pomodoro.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro',
      routes: {
        '/': (context) => const Pomodoro(),
      },
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
    );
  }
}
