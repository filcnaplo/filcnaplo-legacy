import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/globals.dart';
import 'package:filcnaplo/models/account.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo/screens/student_screen.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:flutter/material.dart';

BuildContext ctx;

class GlobalDrawer extends StatefulWidget {
  GlobalDrawerState myState;

  @override
  GlobalDrawerState createState() {
    myState = GlobalDrawerState();
    return myState;
  }
}

class GlobalDrawerState extends State<GlobalDrawer> {
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
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      padding: EdgeInsets.all(2.0),
                    ),
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
            MenuPoint(
                icon: Icons.dashboard,
                text: I18n
                    .of(context)
                    .drawerHome,
                route: "/home",
                screenID: 0),
            MenuPoint(
                icon: IconData(0xF474, fontFamily: "Material Design Icons"),
                text: I18n
                    .of(context)
                    .drawerEvaluations,
                route: "/evaluations",
                screenID: 1),
            MenuPoint(
                icon: IconData(0xf520, fontFamily: "Material Design Icons"),
                text: I18n
                    .of(context)
                    .drawerTimetable,
                route: "/timetable",
                screenID: 2),
            MenuPoint(
                icon: IconData(0xf2dc, fontFamily: "Material Design Icons"),
                text: I18n
                    .of(context)
                    .drawerHomeworks,
                route: "/homework",
                screenID: 8),
            MenuPoint(
                icon: IconData(0xf0e5, fontFamily: "Material Design Icons"),
                text: I18n
                    .of(context)
                    .drawerNotes,
                route: "/notes",
                screenID: 3),
            MenuPoint(
                icon: Icons.assignment,
                text: I18n
                    .of(context)
                    .drawerTests,
                route: "/tests",
                screenID: 10),
            MenuPoint(
                icon: IconData(0xF361, fontFamily: "Material Design Icons"),
                text: I18n
                    .of(context)
                    .drawerMessages,
                route: "/messages",
                screenID: 11),
            MenuPoint(
                icon: Icons.block,
                text: I18n
                    .of(context)
                    .drawerAbsences,
                route: "/absents",
                screenID: 5),
            MenuPoint(
                icon: Icons.supervisor_account,
                text: I18n
                    .of(context)
                    .accountTitle,
                route: "/accounts",
                screenID: 4),
            MenuPoint(
                icon: Icons.settings,
                text: I18n
                    .of(context)
                    .drawerSettings,
                route: "/settings",
                screenID: 7)
          ],
        ),
      ),
    );
  }
}

class MenuPoint extends StatelessWidget {
  final IconData icon;
  final String text;
  final String route;
  final int screenID;

  MenuPoint({this.icon, this.text, this.route, this.screenID});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: screen == screenID ? Theme
            .of(context)
            .accentColor : null,
      ),
      title: Text(
        capitalize(text),
        style: TextStyle(
            color: screen == screenID ? Theme
                .of(context)
                .accentColor : null),
      ),
      onTap: () {
        screen = screenID;
        Navigator.pop(context); // close the drawer
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}