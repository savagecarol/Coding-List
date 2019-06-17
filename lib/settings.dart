import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

Future<bool> getTheme() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("isDark") ?? false;
}

Future<void> setTheme(bool isDark) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("isDark", isDark);
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isDark = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    getSettings();
  }

  getSettings() async {
    bool temp = await getTheme();
    setState(() {
      this.isDark = temp;
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
                final snackbar = SnackBar(
                    content:
                        Text('New theme would be applied from next start.'));
                _scaffoldKey.currentState.showSnackBar(snackbar);
              },
              value: this.isDark,
            ),
          ),
          ListTile(
            onTap: (){
              final snackbar = SnackBar(
                    content:
                        Text('Notifications are coming in next update.'));
                _scaffoldKey.currentState.showSnackBar(snackbar);
            },
            title: Text("Notifications"),
            subtitle: Text("Enable/Disable notifications for contests from different websites.\nComing Soon..."),
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
