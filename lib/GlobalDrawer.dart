import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';

import 'package:filcnaplo/Datas/Account.dart';
import 'package:filcnaplo/Datas/User.dart';
import 'package:filcnaplo/globals.dart';
import 'package:filcnaplo/screens/studentScreen.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';

BuildContext ctx;

class GDrawer extends StatefulWidget {
  GDrawerState myState;

  @override
  GDrawerState createState() {
    myState = GDrawerState();
    return myState;
  }
}

class GDrawerState extends State<GDrawer> {
  @override
  void initState() {
    super.initState();
  }

  void _onSelect(User user) async {
    setState(() {
      selectedUser = user;
      selectedAccount =
          accounts.firstWhere((Account account) => account.user.id == user.id);
    });
    bool popContext = true;
    switch (screen) {
      case 0:
        Navigator.pushReplacementNamed(context, "/home");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/evaluations");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/timetable");
        break;
      case 3:
        Navigator.pushReplacementNamed(context, "/notes");
        break;
      case 5:
        Navigator.pushReplacementNamed(context, "/absents");
        break;
      case 6:
        Navigator.pushReplacementNamed(context, "/evaluations");
        break;
      case 8:
        Navigator.pushReplacementNamed(context, "/homework");
        break;
      case 11:
        Navigator.pushReplacementNamed(context, "/messages");
        break;
      default:
        popContext = false;
        break;
    }
    if (popContext) {
      Navigator.pop(context); // close the drawer
    }
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.5;
    // TODO: implement build
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          children: <Widget>[
            isLogo
                ? Container(
                    child: DrawerHeader(
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            "assets/icon.png",
                            height: 120.0,
                            width: 120.0,
                          ),
                          Container(
                            child: Text(
                              I18n.of(context).appTitle,
                              style: TextStyle(fontSize: 19.0),
                            ),
                            padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
                          ),
                          version != latestVersion && latestVersion != ""
                              ? Card(
                                  child: Container(
                                    child: Text(
                                        "Új verzió elérhető: " + latestVersion,
                                        style: TextStyle(
                                            color: Colors.redAccent[100],
                                            fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2, color: Colors.redAccent)),
                                  ),
                                )
                              : Container(),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      padding: EdgeInsets.all(2.0),
                    ),
                    height: version != latestVersion && latestVersion != ""
                        ? 205.0
                        : 170.0,
                    padding: EdgeInsets.only(left: 10))
                : Container(
                    height: 5,
                  ),
            selectedUser != null && multiAccount
                ? Container(
                    child: DrawerHeader(
                      child: Row(
                        children: <Widget>[
                          PopupMenuButton<User>(
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.account_circle,
                                      color: selectedUser.color,
                                      size: 40,
                                    ),
                                    margin: EdgeInsets.only(right: 5),
                                  ),
                                  Container(
                                    width: 170,
                                    child: Text(
                                      selectedUser.name,
                                      style: TextStyle(
                                        color: null,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: null,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.fromLTRB(10.0, 0.0, 5.0, 6.0),
                            ),
                            onSelected: _onSelect,
                            itemBuilder: (BuildContext context) {
                              return users.map((User user) {
                                return PopupMenuItem<User>(
                                  value: user,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.account_circle,
                                        color: user.color,
                                      ),
                                      Text(user.name),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                          ),
                          Expanded(child: Container()),
                          IconButton(
                            icon: Icon(
                              Icons.info,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () {
                              Navigator.pop(context); // close the drawer
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          StudentScreen(
                                            account: selectedAccount,
                                          )));
                            },
                            padding: EdgeInsets.only(right: 10),
                          ),
                        ],
                        mainAxisSize: MainAxisSize.max,
                      ),
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.all(0),
                    ),
                    height: 60,
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                  )
                : Container(),
            ListTile(
              leading: Icon(
                Icons.dashboard,
                color: screen == 0 ? Theme.of(context).accentColor : null,
              ),
              title: Text(
                capitalize(I18n.of(context).drawerHome),
                style: TextStyle(
                    color: screen == 0 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 0;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/home");
              },
            ),
            ListTile(
              leading: Icon(
                IconData(0xF474, fontFamily: "Material Design Icons"),
                color: screen == 1 ? Theme.of(context).accentColor : null,
              ),
              title: Text(
                capitalize(I18n.of(context).drawerEvaluations),
                style: TextStyle(
                    color: screen == 1 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 1;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/evaluations");
              },
            ),
            ListTile(
              leading: Icon(
                IconData(0xf520, fontFamily: "Material Design Icons"),
                color: screen == 2 ? Theme.of(context).accentColor : null,
              ),
              title: Text(
                capitalize(I18n.of(context).timetable),
                style: TextStyle(
                    color: screen == 2 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 2;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/timetable");
              },
            ),
            ListTile(
              leading: Icon(
                IconData(0xf2dc, fontFamily: "Material Design Icons"),
                color: screen == 8 ? Theme.of(context).accentColor : null,
              ),
              title: Text(
                capitalize(I18n.of(context).drawerHomeworks),
                style: TextStyle(
                    color: screen == 8 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 8;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/homework");
              },
            ),
            ListTile(
              leading: Icon(
                IconData(0xf0e5, fontFamily: "Material Design Icons"),
                color: screen == 3 ? Theme.of(context).accentColor : null,
              ),
              title: Text(
                capitalize(I18n.of(context).drawerNotes),
                style: TextStyle(
                    color: screen == 3 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 3;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/notes");
              },
            ),
            ListTile(
              leading: Icon(
                Icons.assignment,
                color: screen == 10 ? Theme.of(context).accentColor : null,
              ),
              title: Text(
                capitalize(I18n.of(context).drawerTests),
                style: TextStyle(
                    color: screen == 10 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 10;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/tests");
              },
            ),
            ListTile(
              leading: Icon(
                IconData(0xF361, fontFamily: "Material Design Icons"),
                color: screen == 11 ? Theme.of(context).accentColor : null,
              ),
              title: Text(
                capitalize(I18n.of(context).drawerMessages),
                style: TextStyle(
                    color: screen == 11 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 11;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/messages");
              },
            ),
            ListTile(
              leading: Icon(
                Icons.block,
                color: screen == 5 ? Theme.of(context).accentColor : null,
              ),
              title: Text(
                capitalize(I18n.of(context).drawerAbsences),
                style: TextStyle(
                    color: screen == 5 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 5;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/absents");
              },
            ),
            
             ListTile(
               leading: Icon(
                 Icons.supervisor_account,
                 color: screen == 4 ? Theme.of(context).accentColor : null,
               ),
               title: Text(
                 capitalize(I18n.of(context).accountTitle),
                 style: TextStyle(
                     color: screen == 4 ? Theme.of(context).accentColor : null),
               ),
               onTap: () {
                 screen = 4;
                 Navigator.pop(context); // close the drawer
                 Navigator.pushReplacementNamed(context, "/accounts");
               },
             ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: screen == 7 ? Theme.of(context).accentColor : null,
              ),
              title: Text(
                capitalize(I18n.of(context).drawerSettings),
                style: TextStyle(
                    color: screen == 7 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 7;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/settings");
              },
            ),
          ],
        ),
      ),
    );
  }
}
