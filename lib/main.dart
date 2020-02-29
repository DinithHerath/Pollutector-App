import 'package:flutter/material.dart';
import 'package:pollutector_app_v1/Services/authentication.dart';
import 'package:pollutector_app_v1/Setup/root_page.dart';

void main() => runApp(PollutectorApp());

class PollutectorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Pollutector App',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(   
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(auth: new Auth())
    );
  }
}