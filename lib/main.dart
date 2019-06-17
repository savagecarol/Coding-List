import 'dart:io';
import 'package:flutter/material.dart';
import 'package:coding_list/tabs.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> getTheme() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("isDark") ?? false;
}


String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544~1458002511';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-2643040473892428~6996314381';
  }
  return null;
}

bool isDarkTheme;

main() async {
  isDarkTheme = await getTheme();
  print(isDarkTheme);
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
        brightness: isDarkTheme ? Brightness.dark : Brightness.light 
      ),
      home: HomePage(),
    );
  }
}