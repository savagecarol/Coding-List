import 'package:coding_list/fetchData.dart';
// import 'package:coding_list/problems.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quiver/async.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class ContestPage extends StatefulWidget {
  final Contest contest;
  ContestPage(this.contest);

  @override
  _ContestPage createState() => _ContestPage();
}

class _ContestPage extends State<ContestPage> {
  String remainingTime = "00:00:00";
  String timerText = "";

  CountdownTimer upcomingContestTimer;
  var sub;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var eventaddoption = false;
    if (this.widget.contest.start.isAfter(new DateTime.now())) {
      timerText = "Contest starting in";
      upcomingContestTimer = new CountdownTimer(
        new Duration(
            seconds: this
                .widget
                .contest
                .start
                .difference(new DateTime.now())
                .inSeconds),
        new Duration(seconds: 1),
      );
      sub = upcomingContestTimer.listen(null);
      sub.onData((duration) {
        if (mounted) {
          var t = upcomingContestTimer.remaining.toString();
          setState(() {
            remainingTime = t.substring(0, t.length - 7);
          });
        }
      });
      sub.onDone(() {
        sub.cancel();
      });
      eventaddoption = true;
    } else if (this.widget.contest.end.isBefore(new DateTime.now())) {
      timerText = "Contest ended";
    } else {
      timerText = "Contest ending in";
      upcomingContestTimer = new CountdownTimer(
        new Duration(
            seconds: this
                .widget
                .contest
                .end
                .difference(new DateTime.now())
                .inSeconds),
        new Duration(seconds: 1),
      );
      sub = upcomingContestTimer.listen(null);
      sub.onData((duration) {
        if (mounted) {
          var t = upcomingContestTimer.remaining.toString();
          setState(() {
            remainingTime = t.substring(0, t.length - 7);
          });
        }
      });
      sub.onDone(() {
        sub.cancel();
      });
    }

    var start = this.widget.contest.start.toString().split(" ");
    var end = this.widget.contest.end.toString().split(" ");

    var duration = "";
    var timeins = this.widget.contest.duration;
    var temp = (timeins ~/ (24 * 60 * 60));
    if (temp != 0) {
      duration += temp.toString();
      if (temp == 1) {
        duration += " day ";
      } else {
        duration += " days ";
      }
    }
    timeins -= temp * 24 * 60 * 60;
    temp = (timeins ~/ (60 * 60));
    if (temp != 0) {
      duration += temp.toString();
      if (temp == 1) {
        duration += " hour ";
      } else {
        duration += " hours ";
      }
    }
    timeins -= temp * 60 * 60;
    temp = (timeins ~/ (60));
    if (temp != 0) {
      duration += temp.toString();
      if (temp == 1) {
        duration += " minute ";
      } else {
        duration += " minutes ";
      }
    }
    timeins -= temp * 60;
    temp = timeins;
    if (temp != 0) {
      duration += temp.toString();
      if (temp == 1) {
        duration += " second ";
      } else {
        duration += " seconds ";
      }
    }
    var nam = this.widget.contest.resource.toLowerCase().split(".")[0];
    final Event event = Event(
      title: this.widget.contest.event,
      description: this.widget.contest.resource,
      location: this.widget.contest.href,
      startDate: this.widget.contest.start,
      endDate: this.widget.contest.end,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.contest.event),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.link),
            onPressed: () {
              launchURL(this.widget.contest.href);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    timerText,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    remainingTime,
                    style: TextStyle(
                      fontSize: 26.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    "Duration",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 26.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    "Platform",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    this.widget.contest.resource,
                    style: TextStyle(
                      fontSize: 26.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(padding: const EdgeInsets.all(2.0)),
                  Image.asset(
                    'assets/icons/$nam.${[
                      "yukicoder",
                      "kaggle",
                      "projecteuler",
                      "codechef",
                      "e-olymp",
                      "opencup"
                    ].contains(nam) ? "ico" : "png"}',
                    errorBuilder: (context, error, stackTrace) {
                      return Container();
                    },
                    width: 48,
                    height: 48,
                  )
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "Starts at",
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w600),
                      ),
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
                        "Ends at",
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w600),
                      ),
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
              ),
            ),
          ),
          // (
          //   timerText.contains("ended") ?
          //     GestureDetector(
          //     onTap: ()=>{
          //       this.widget.contest.resource.contains(RegExp(r"(codeforces|ctftime)")) ?
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (BuildContext context) => ProblemsPage(this.widget.contest)
          //           )
          //         )
          //       :
          //         print(["not implemented", this.widget.contest.href])
          //     },
          //     child: Card(
          //       child: Padding(
          //         padding: const EdgeInsets.all(18.0),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.stretch,
          //           mainAxisSize: MainAxisSize.max,
          //           children: <Widget>[
          //             Text(
          //               "Problems & Solutions",
          //               style: TextStyle(
          //                 fontSize: 26.0,
          //               ),
          //               textAlign: TextAlign.center,
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   )
          // :
          //   Container()
          // )
          (eventaddoption
              ? GestureDetector(
                  onTap: () => Add2Calendar.addEvent2Cal(event),
                  child: Card(
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text(
                            "Add to Calendar",
                            style:
                                TextStyle(fontSize: 22.0, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ))
              : Container()),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    if (sub != null) {
      sub.cancel();
    }
    super.dispose();
  }
}
