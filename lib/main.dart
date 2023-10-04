// ignore_for_file: prefer_const_constructors
import 'package:flappy_bard/home_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  get databaseHelper => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fluppy-bird-3',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Game',
        ),
        home: HomePage());
  }
}
