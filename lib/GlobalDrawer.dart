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
    myState = new GDrawerState();
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
        Navigator.pushReplacementNamed(context, "/main");
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
    return new Drawer(
      child: new Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: new ListView(
          children: <Widget>[
            isLogo
                ? new Container(
                    child: new DrawerHeader(
                      child: new Column(
                        children: <Widget>[
                          Image.asset(
                            "assets/icon.png",
                            height: 120.0,
                            width: 120.0,
                          ),
                          new Container(
                            child: new Text(
                              I18n.of(context).appTitle,
                              style: TextStyle(fontSize: 19.0),
                            ),
                            padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
                          ),
                          version != latestVersion && latestVersion != ""
                              ? new Card(
                                  child: Container(
                                    child: new Text(
                                        "Új verzió elérhető: " + latestVersion,
                                        style: new TextStyle(
                                            color: Colors.redAccent[100],
                                            fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.all(5),
                                    decoration: new BoxDecoration(
                                        border: Border.all(
                                            width: 2, color: Colors.redAccent)),
                                  ),
                                )
                              : new Container(),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      padding: EdgeInsets.all(2.0),
                    ),
                    height: version != latestVersion && latestVersion != ""
                        ? 205.0
                        : 170.0,
                    padding: EdgeInsets.only(left: 10))
                : new Container(
                    height: 5,
                  ),
            selectedUser != null && multiAccount
                ? new Container(
                    child: new DrawerHeader(
                      child: Row(
                        children: <Widget>[
                          new PopupMenuButton<User>(
                            child: new Container(
                              child: new Row(
                                children: <Widget>[
                                  new Container(
                                    child: new Icon(
                                      Icons.account_circle,
                                      color: selectedUser.color,
                                      size: 40,
                                    ),
                                    margin: EdgeInsets.only(right: 5),
                                  ),
                                  new Container(
                                    width: 170,
                                    child: Text(
                                      selectedUser.name,
                                      style: new TextStyle(
                                        color: null,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  new Icon(
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
                                return new PopupMenuItem<User>(
                                  value: user,
                                  child: new Row(
                                    children: <Widget>[
                                      new Icon(
                                        Icons.account_circle,
                                        color: user.color,
                                      ),
                                      new Text(user.name),
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
                                  new MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          new StudentScreen(
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
                : new Container(),
            new ListTile(
              leading: new Icon(
                Icons.dashboard,
                color: screen == 0 ? Theme.of(context).accentColor : null,
              ),
              title: new Text(
                capitalize(I18n.of(context).drawerHome),
                style: TextStyle(
                    color: screen == 0 ? Theme.of(context).accentColor : null),
              ),
              onTap: () {
                screen = 0;
                Navigator.pop(context); // close the drawer
                Navigator.pushReplacementNamed(context, "/main");
              },
            ),
            new ListTile(
              leading: new Icon(
                IconData(0xF474, fontFamily: "Material Design Icons"),
                color: screen == 1 ? Theme.of(context).accentColor : null,
              ),
              title: new Text(
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
            new ListTile(
              leading: new Icon(
                IconData(0xf520, fontFamily: "Material Design Icons"),
                color: screen == 2 ? Theme.of(context).accentColor : null,
              ),
              title: new Text(
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
            new ListTile(
              leading: new Icon(
                IconData(0xf2dc, fontFamily: "Material Design Icons"),
                color: screen == 8 ? Theme.of(context).accentColor : null,
              ),
              title: new Text(
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
            new ListTile(
              leading: new Icon(
                IconData(0xf0e5, fontFamily: "Material Design Icons"),
                color: screen == 3 ? Theme.of(context).accentColor : null,
              ),
              title: new Text(
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
            new ListTile(
              leading: new Icon(
                Icons.assignment,
                color: screen == 10 ? Theme.of(context).accentColor : null,
              ),
              title: new Text(
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
            new ListTile(
              leading: new Icon(
                IconData(0xF361, fontFamily: "Material Design Icons"),
                color: screen == 11 ? Theme.of(context).accentColor : null,
              ),
              title: new Text(
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
            new ListTile(
              leading: new Icon(
                Icons.block,
                color: screen == 5 ? Theme.of(context).accentColor : null,
              ),
              title: new Text(
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
            /*
             new ListTile(
               leading: new Icon(
                 Icons.supervisor_account,
                 color: screen == 4 ? Theme.of(context).accentColor : null,
               ),
               title: new Text(
                 capitalize(I18n.of(context).accountTitle),
                 style: TextStyle(
                     color: screen == 4 ? Theme.of(context).accentColor : null),
               ),
               onTap: () {
                 screen = 4;
                 Navigator.pop(context); // close the drawer
                 Navigator.pushReplacementNamed(context, "/accounts");
               },
             ),*/
            new ListTile(
              leading: new Icon(
                Icons.settings,
                color: screen == 7 ? Theme.of(context).accentColor : null,
              ),
              title: new Text(
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
