import 'package:coding_list/fetchData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'dart:io';
import 'package:share/share.dart';

String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544~1458002511';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-2643040473892428~6996314381';
  }
  return null;
}

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-2643040473892428/8094661681';
  }
  return null;
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

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

  _HomeState(){
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      }
      else {
        setState(() {
          _isSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  List<Contest> getSearchContests(List<Contest> allcontests){
    if(_searchText.isEmpty){
      return allcontests;
    }

    List<Contest> _list = [];
    for (var i = 0; i < allcontests.length; i++) {
      if(allcontests[i].event.toLowerCase().contains(_searchText.toLowerCase()) || allcontests[i].resource.toLowerCase().contains(_searchText.toLowerCase())){
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
            return ContestListWidget("live", _isSearching ? getSearchContests(snapshot.data.contests) : snapshot.data.contests);
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
            return ContestListWidget("upcoming", _isSearching ? getSearchContests(snapshot.data.contests) : snapshot.data.contests);
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
            return ContestListWidget("completed", _isSearching ? getSearchContests(snapshot.data.contests) : snapshot.data.contests);
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
        // centerTitle: true,
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
            icon: Icon(Icons.share),
            onPressed: (){
              Share.share("""Hey, download the *Coding List* app. https://play.google.com/store/apps/details?id=io.github.vikasgola.coding_list""");
            },
          )
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

class ContestListWidget extends StatefulWidget {
  final String which;
  final List<Contest> contests;
  ContestListWidget(this.which, this.contests);
  @override
  _ContestListWidgetState createState() => _ContestListWidgetState();
}

class _ContestListWidgetState extends State<ContestListWidget> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    if (this.widget.contests.length == 0) {
      return Container(
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No Contests!!!",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        key: PageStorageKey(this.widget.which),
        itemBuilder: (context, position) {
          var start =
              this.widget.contests[position].start.toString().split(" ");
          var end = this.widget.contests[position].end.toString().split(" ");
          return InkWell(
              onTap: () {
                launchURL(this.widget.contests[position].href);
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0.0),
                      child: Text(
                        this.widget.contests[position].event,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        this.widget.contests[position].resource,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              start[0],
                              style: TextStyle(fontSize: 14.0),
                            ),
                            Text(
                              start[1].split(".")[0],
                              style: TextStyle(fontSize: 14.0),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              end[0],
                              style: TextStyle(fontSize: 14.0),
                            ),
                            Text(
                              end[1].split(".")[0],
                              style: TextStyle(fontSize: 14.0),
                            )
                          ],
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    )
                  ]),
                ),
              ));
        },
        separatorBuilder: (context, position) {
          if (position % 3 == 0) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: AdmobBanner(
                    adUnitId: getBannerAdUnitId(),
                    adSize: AdmobBannerSize.LARGE_BANNER,
                    listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                      switch (event) {
                        case AdmobAdEvent.loaded:
                          print('Admob banner loaded!');
                          break;

                        case AdmobAdEvent.opened:
                          print('Admob banner opened!');
                          break;

                        case AdmobAdEvent.closed:
                          print('Admob banner closed!');
                          break;

                        case AdmobAdEvent.failedToLoad:
                          print(
                              'Admob banner failed to load. Error code: ${args['errorCode']}');
                          break;
                        default:
                          break;
                      }
                    }),
              ),
            );
          } else {
            return Card();
          }
        },
        itemCount: this.widget.contests.length,
      ),
    );
  }
}
