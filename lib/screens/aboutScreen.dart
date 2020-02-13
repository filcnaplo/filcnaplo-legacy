import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:filcnaplo/GlobalDrawer.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';

void main() {
  runApp(new MaterialApp(
    home: new AboutScreen(),
    localizationsDelegates: const <LocalizationsDelegate<WidgetsLocalizations>>[
      I18n.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: I18n.delegate.supportedLocales,
    onGenerateTitle: (BuildContext context) => I18n.of(context).appTitle,
  ));
}

class AboutScreen extends StatefulWidget {
  @override
  AboutScreenState createState() => new AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  //TODO: Easter egg code really needed?
  /*
      int clicksUntilEasteregg = 5;
      bool showEasteregg = false;
      void battleRoyaleCounter() {
          if (clicksUntilEasteregg > 1) {
              clicksUntilEasteregg--;
              Fluttertoast.showToast(msg: clicksUntilEasteregg.toString() + " lépésre vagy a battle royale módtól!", backgroundColor: Colors.black, textColor: Colors.white, fontSize: 16.0);
          } else if (!showEasteregg) {
              showEasteregg = true;
              //globals.behaveNicely = false;
              RequestHelper().refreshAppSettings();
              Fluttertoast.showToast(msg: "" , backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
              Navigator.pushReplacementNamed(context, "/easteregg");
          }
      }
      */
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () {
          globals.screen = 7;
          Navigator.pushReplacementNamed(context, "/settings");
        },
        child: Scaffold(
          drawer: GDrawer(),
          appBar: new AppBar(
            title: new Text(I18n.of(context).appTitle),
            actions: <Widget>[],
          ),
          body: new Center(
            child: Container(
              child: new ListView(
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  new Container(
                    child: new Text(
                      I18n.of(context).appTitle,
                      style: new TextStyle(
                        fontSize: 28.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    padding: EdgeInsets.only(bottom: 30.0),
                  ),
                  new Row(
                    children: <Widget>[
                      new Text(
                        capitalize(I18n.of(context).appVersion) + ":",
                        style: new TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                      new Text(
                        globals.version,
                        style: new TextStyle(
                            fontSize: 22.0,
                            color: Theme.of(context).accentColor),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  new Row(
                    children: <Widget>[
                      new Text(
                        "User-Agent:",
                        style: new TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                      new Text(
                        "\n" + globals.userAgent,
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  (globals.selectedUser ==
                          null) //If there is no user selected, show a button to go back to login screen.
                      ? new Container(
                          child: new RaisedButton(
                            onPressed: _popToLogin,
                            child: new Text(
                              "Vissza a bejelentkezéshez",
                              style: new TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(5))
                      : new Container(),
                ],
              ),
            ),
          ),
        ));
  }

  _popToLogin() {
    Navigator.pushNamed(context, "/login");
  }
}
