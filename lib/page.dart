import 'package:coding_list/contest.dart';
import 'package:coding_list/fetchData.dart';
import 'package:flutter/material.dart';

openContestPage(Contest contest, BuildContext context) {
  Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => ContestPage(contest)));
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
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        key: PageStorageKey(this.widget.which),
        itemBuilder: (context, position) {
          var start =
              this.widget.contests[position].start.toString().split(" ");
          var end = this.widget.contests[position].end.toString().split(" ");
          return InkWell(
              onTap: () {
                openContestPage(this.widget.contests[position], context);
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
                              "Start",
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w600),
                            ),
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
                              "End",
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w600),
                            ),
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
                    ),
                  ]),
                ),
              ));
        },
        itemCount: this.widget.contests.length,
      ),
    );
  }
}
