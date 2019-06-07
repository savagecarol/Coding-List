import 'package:flutter/material.dart';
import 'package:coding_list/tabs.dart';
import 'package:admob_flutter/admob_flutter.dart';
// import 'package:background_fetch/background_fetch.dart';
// import 'dart:async';
// import 'package:flutter/services.dart';

main() {
  Admob.initialize(getAppId());
  runApp(new App());
  // FetchData fetchData = new FetchData();
  // fetchData.initPlatformState();
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

// void backgroundFetchHeadlessTask() async {
//   print('[BackgroundFetch] Headless event received.');
//   BackgroundFetch.finish();
// }


class App extends StatelessWidget {
  // This widget is the root of your application.
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