import 'package:flutter/material.dart';
import 'package:my_companion_app/ui/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget{

  @override
  MyAppState createState() => new MyAppState();
} 
class MyAppState extends State<MyApp>{

  @override
  Widget build (BuildContext context){
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Home(),
     routes: <String, WidgetBuilder>{
      '/home': (context) => Home(),
    },
    );
  }
}

