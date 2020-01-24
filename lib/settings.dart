import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'package:coding_list/multiselect.dart';
import 'package:coding_list/main.dart';


Future<bool> getTheme() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("isDark") ?? false;
}

Future<void> setTheme(bool isDark) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("isDark", isDark);
}

// Future<List<int>> getNotificationSettings() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   final out = prefs.getStringList("notification-settings") ??
//       ["0","1", "2", "3", "4", "5", "6", "7", "8"];
//   return out.map((i) => int.parse(i)).toList();
// }

// Future<void> setNotificationSettings(List<int> list) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setStringList(
//       "notification-settings", list.map((i) => i.toString()).toList());
// }

Future<List<int>> getVisibleSettings() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final out = prefs.getStringList("visible-settings") ??
      ["0","1", "2", "3", "4", "5", "6", "7", "8", "9"];
  return out.map((i) => int.parse(i)).toList();
}

Future<void> setVisibleSettings(List<int> list) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(
      "visible-settings", list.map((i) => i.toString()).toList());
}


class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isDark = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final items = <MultiSelectDialogItem<int>>[
    MultiSelectDialogItem(1, 'Codeforces'),
    MultiSelectDialogItem(2, 'Codechef'),
    MultiSelectDialogItem(3, 'Hackerearth'),
    MultiSelectDialogItem(4, 'Hackerrank'),
    MultiSelectDialogItem(5, 'Leetcode'),
    MultiSelectDialogItem(6, 'Kaggle'),
    MultiSelectDialogItem(7, 'ctftime'),
    MultiSelectDialogItem(8, 'Topcoder'),
    MultiSelectDialogItem(9, 'Atcoder'),
    MultiSelectDialogItem(0, 'Others'),
  ];
  // List<int> notify = [];
  List<int> visible = [];

  @override
  initState() {
    super.initState();
    getSettings();
  }

  getSettings() async {
    bool temp = await getTheme();
    List<int> temp2 = await getVisibleSettings();
    // List<int> temp2 = await getNotificationSettings();
    setState(() {
      this.isDark = temp;
      this.visible = temp2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
          child: ListView(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        children: <Widget>[
          ListTile(
            title: Text("Dark Theme"),
            subtitle: Text("Enable/Disable dark theme"),
            trailing: Switch(
              onChanged: (bool value) {
                setState(() {
                  this.isDark = value;
                  setTheme(this.isDark);
                });
                RestartWidget.restartApp(context);
                // final snackbar = SnackBar(
                //     content: Text('New theme would be applied on next start.'));
                // _scaffoldKey.currentState.showSnackBar(snackbar);
              },
              value: this.isDark,
            ),
          ),
          // ListTile(
          //   onTap: () async {
          //     final selectedValues = await showDialog<Set<int>>(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return MultiSelectDialog(
          //           items: items,
          //           initialSelectedValues: this.notify.toSet(),
          //         );
          //       },
          //     );
          //     setState(() {
          //       if (selectedValues != null){
          //         this.notify = selectedValues.toList();
          //         setNotificationSettings(this.notify);
          //       }
          //     });
          //   },
          //   title: Text("Notifications"),
          //   subtitle: Text("Get notifications of contests."),
          //   trailing: Icon(Icons.notifications),
          // ),
          ListTile(
            onTap: () async {
              final selectedValues = await showDialog<Set<int>>(
                context: context,
                builder: (BuildContext context) {
                  return MultiSelectDialog(
                    title: "Show contests from...",
                    items: items,
                    initialSelectedValues: this.visible.toSet(),
                  );
                },
              );
              setState(() {
                if (selectedValues != null){
                  this.visible = selectedValues.toList();
                  setVisibleSettings(this.visible);
                  RestartWidget.restartApp(context);
                }
              });
            },
            title: Text("Contests"),
            subtitle: Text("show contests only from."),
            trailing: Icon(Icons.list),
          ),
          ListTile(
            onTap: () {
              Share.share(
                  """Hey, download the *Coding List* app. https://play.google.com/store/apps/details?id=io.github.vikasgola.coding_list""");
            },
            title: Text("Share"),
            subtitle: Text("Love the app! Share with your friends."),
            trailing: Icon(Icons.share),
          ),
        ],
      )),
    );
  }
}
