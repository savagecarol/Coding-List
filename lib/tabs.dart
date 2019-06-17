import 'package:coding_list/fetchData.dart';
import 'package:coding_list/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coding_list/settings.dart';
// import 'dart:async';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ErrorCardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      },
      child: Container(
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No internet!!! Try restarting App.",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            Container(
              child: new Text("Loading..."),
              margin: EdgeInsets.only(left: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int _currentIndex = 0;
  final key = new GlobalKey<ScaffoldState>();
  final PageStorageBucket bucket = PageStorageBucket();
  List<Widget> _children = [];
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget appBarTitle = Text('Coding List');
  final TextEditingController _searchQuery = new TextEditingController();
  bool _isSearching = false;
  String _searchText = "";

  // Future onSelectNotification(String payload) async {
  //   if (payload != null) {
  //     debugPrint('notification payload: ' + payload);
  //   }
  //   await Navigator.push(
  //     context,
  //     new MaterialPageRoute(builder: (context) => new HomePage()),
  //   );
  // }

  // Future onDidReceiveLocalNotification(
  //     int id, String title, String body, String payload) async {
  //   showDialog(
  //       context: context, builder: (BuildContext context) => new Text("Hello"));
  // }

  @override
  initState() {
    super.initState();
    // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // var initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOS = IOSInitializationSettings(
    //     onDidReceiveLocalNotification: this.onDidReceiveLocalNotification);
    // var initializationSettings = InitializationSettings(
    //     initializationSettingsAndroid, initializationSettingsIOS);

    // flutterLocalNotificationsPlugin
    //     .initialize(initializationSettings,
    //         onSelectNotification: this.onSelectNotification)
    //     .then((onValue) async {
    //   await _scheduleNotification();
    // });
  }

  // Future<void> _scheduleNotification() async {
  //   var scheduledNotificationDateTime =
  //       DateTime.now().add(Duration(seconds: 5));

  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'your other channel id',
  //       'your other channel name',
  //       'your other channel description',
  //       largeIconBitmapSource: BitmapSource.Drawable,
  //       enableLights: true,
  //       color: const Color.fromARGB(255, 255, 0, 0),
  //       ledColor: const Color.fromARGB(255, 255, 0, 0),
  //       ledOnMs: 1000,
  //       importance: Importance.Max,
  //       priority: Priority.High,
  //       ledOffMs: 500);
  //   var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  //   var platformChannelSpecifics = NotificationDetails(
  //       androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.schedule(
  //       0,
  //       'scheduled title',
  //       'scheduled body',
  //       scheduledNotificationDateTime,
  //       platformChannelSpecifics);
  // }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = Text('Coding List');
      _isSearching = false;
      _searchQuery.clear();
    });
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  _HomeState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  List<Contest> getSearchContests(List<Contest> allcontests) {
    if (_searchText.isEmpty) {
      return allcontests;
    }

    List<Contest> _list = [];
    for (var i = 0; i < allcontests.length; i++) {
      if (allcontests[i]
              .event
              .toLowerCase()
              .contains(_searchText.toLowerCase()) ||
          allcontests[i]
              .resource
              .toLowerCase()
              .contains(_searchText.toLowerCase())) {
        _list.add(allcontests[i]);
      }
    }

    return _list;
  }

  @override
  Widget build(BuildContext context) {
    _children = [
      FutureBuilder<Contests>(
        future: liveContests,
        builder: (contests, snapshot) {
          if (snapshot.hasData) {
            return ContestListWidget(
                "live",
                _isSearching
                    ? getSearchContests(snapshot.data.contests)
                    : snapshot.data.contests);
          } else if (snapshot.hasError) {
            return ErrorCardWidget();
          }
          return ProgressBarWidget();
        },
      ),
      FutureBuilder<Contests>(
        future: upcomingContests,
        builder: (contests, snapshot) {
          if (snapshot.hasData) {
            return ContestListWidget(
                "upcoming",
                _isSearching
                    ? getSearchContests(snapshot.data.contests)
                    : snapshot.data.contests);
          } else if (snapshot.hasError) {
            return ErrorCardWidget();
          }
          return ProgressBarWidget();
        },
      ),
      FutureBuilder<Contests>(
        future: completedContests,
        builder: (contests, snapshot) {
          if (snapshot.hasData) {
            return ContestListWidget(
                "completed",
                _isSearching
                    ? getSearchContests(snapshot.data.contests)
                    : snapshot.data.contests);
          } else if (snapshot.hasError) {
            return ErrorCardWidget();
          }
          return ProgressBarWidget();
        },
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: this.appBarTitle,
        key: this.key,
        actions: <Widget>[
          new IconButton(
            icon: this.actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = new Icon(
                    Icons.close,
                    color: Colors.white,
                  );
                  this.appBarTitle = new TextField(
                    controller: _searchQuery,
                    style: new TextStyle(
                      color: Colors.white,
                    ),
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: new Icon(Icons.search, color: Colors.white),
                      hintText: " Search...",
                      hintStyle: new TextStyle(color: Colors.white),
                    ),
                  );
                  _handleSearchStart();
                } else {
                  _handleSearchEnd();
                }
              });
            },
          ),
          new IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Settings()));
            },
          ),
        ],
      ),
      body: PageStorage(
        bucket: bucket,
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            title: Text('Live'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.update),
            title: Text('Upcoming'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.done),
            title: Text('Completed'),
          )
        ],
      ),
    );
  }
}
