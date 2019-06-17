
import 'dart:io';
import 'package:coding_list/fetchData.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admob_flutter/admob_flutter.dart';

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-2643040473892428/8094661681';
  }
  return null;
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
                          break;
                        case AdmobAdEvent.opened:
                          break;
                        case AdmobAdEvent.closed:
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
