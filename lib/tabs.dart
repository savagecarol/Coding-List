import 'package:coding_list/fetchData.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'dart:io';

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

class ProgressBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Dialog(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            Container(child: new Text("Loading..."), margin: EdgeInsets.only(left: 16.0),),
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
  final List<Widget> _children = [
    FutureBuilder<Contests>(
      future: liveContests,
      builder: (contests, snapshot) {
        if (snapshot.hasData) {
          return ContestListWidget("live", snapshot.data.contests);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return ProgressBarWidget();
      },
    ),
    FutureBuilder<Contests>(
      future: upcomingContests,
      builder: (contests, snapshot) {
        if (snapshot.hasData) {
          return ContestListWidget("upcoming", snapshot.data.contests);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return ProgressBarWidget();
      },
    ),
    FutureBuilder<Contests>(
      future: completedContests,
      builder: (contests, snapshot) {
        if (snapshot.hasData) {
          return ContestListWidget("completed", snapshot.data.contests);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return ProgressBarWidget();
      },
    )
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coding List'),
      ),
      body: _children[_currentIndex],
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

class ContestListWidget extends StatelessWidget {
  final String which;
  final List<Contest> contests;

  ContestListWidget(this.which, this.contests);

  @override
  Widget build(BuildContext context) {
    if (this.contests.length == 0) {
      return Container(
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No Contests!!!",
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, position) {
          var start = this.contests[position].start.toString().split(" ");
          var end = this.contests[position].end.toString().split(" ");
          return GestureDetector(
              onTap: () {
                launchURL(this.contests[position].href);
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                      child: Text(
                        this.contests[position].event,
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        this.contests[position].resource,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              start[0],
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Text(
                              start[1].split(".")[0],
                              style: TextStyle(fontSize: 18.0),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              end[0],
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Text(
                              end[1].split(".")[0],
                              style: TextStyle(fontSize: 18.0),
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
          if (position % 4 == 0 && position != 0) {
            return Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
        itemCount: this.contests.length,
      ),
    );
  }
}
