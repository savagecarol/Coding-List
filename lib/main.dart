import 'package:flutter/material.dart';
import 'package:coding_list/tabs.dart';
import 'package:admob_flutter/admob_flutter.dart';

main() {
  Admob.initialize(getAppId());
  runApp(new App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coding List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // brightness: Brightness.dark
      ),
      home: HomePage(),
    );
  }
}