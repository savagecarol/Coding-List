import 'package:coding_list/fetchData.dart';
import 'package:coding_list/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coding_list/settings.dart';
// import 'package:coding_list/notification.dart';

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
  final String payload;
  final List<int> visible;
  HomePage(this.payload, this.visible);

  @override
  _HomeState createState(){
    return new _HomeState(this.payload);
  }
}

class _HomeState extends State<HomePage> {
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

  Map<int, String> list = {
    1: 'Codeforces',
    2: 'Codechef',
    3: 'Hackerearth',
    4: 'Hackerrank',
    5: 'Leetcode',
    6: 'Kaggle',
    7: 'ctftime',
    8: 'Topcoder',
    9: 'Atcoder',
    0: 'Others',
  };

  @override
  initState() {
    super.initState();
    // fetchSettings();
  }

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

  _HomeState(String payload) {
    // if (payload != "") launchURL(payload);
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          this._isSearching = false;
          this._searchText = "";
        });
      } else {
        setState(() {
          this._isSearching = true;
          this._searchText = _searchQuery.text;
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

  bool _shouldVisible(Contest contest) {
    bool shouldAdd = false;

    widget.visible.forEach((i) {
      if (contest.href.contains(this.list[i].toLowerCase())) {
        shouldAdd = true;
      }
    });
    if (!shouldAdd && widget.visible.contains(0)) {
      shouldAdd = true;
      this.list.forEach((i, name) {
        if (contest.href.contains(name.toLowerCase())) {
          shouldAdd = false;
        }
      });
    }
    return shouldAdd;
  }

  List<Contest> felterContests(List<Contest> contests) {
    List<Contest> temp = [];

    contests.forEach((contest) {
      if (_shouldVisible(contest)) {
        temp.add(contest);
      }
    });
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    _children = [
      FutureBuilder<Contests>(
        future: liveContests,
        builder: (contests, snapshot) {
          if (snapshot.hasData) {
            List<Contest> contests = snapshot.data.contests;
            List<Contest> filtered = felterContests(contests);
            return ContestListWidget(
                "live", _isSearching ? getSearchContests(filtered) : filtered);
          } else if (snapshot.hasError) {
            return ErrorCardWidget();
          }
          return ProgressBarWidget();
        },
      ),
      FutureBuilder<Contests>(
        future: upcomingContests,
        builder: (contests, snapshot) {
          // initNotifications(snapshot.data.contests, context);
          if (snapshot.hasData) {
            List<Contest> contests = snapshot.data.contests;
            List<Contest> filtered = felterContests(contests);
            return ContestListWidget("upcoming",
                _isSearching ? getSearchContests(filtered) : filtered);
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
            List<Contest> contests = snapshot.data.contests;
            List<Contest> filtered = felterContests(contests);
            return ContestListWidget("completed",
                _isSearching ? getSearchContests(filtered) : filtered);
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
        selectedItemColor: Colors.blue,
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
