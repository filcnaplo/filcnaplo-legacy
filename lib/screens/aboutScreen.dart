import 'dart:ui';
import 'package:flutter/material.dart';
import '../GlobalDrawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:filcnaplo/generated/i18n.dart';
import '../globals.dart' as globals;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_html/flutter_html.dart';
import '../Helpers/RequestHelper.dart';

void main() {
  runApp(new MaterialApp(
    home: new AboutScreen(),
    localizationsDelegates: const <LocalizationsDelegate<WidgetsLocalizations>>[
      S.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    onGenerateTitle: (BuildContext context) => .title,
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
            title: new Text(.title),
            actions: <Widget>[],
          ),
          body: new Center(
            child: Container(
              child: new ListView(
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  new Container(
                    child: new Text(
                      .title,
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
                        .version,
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
                  Container(
                    child: new Row(
                      children: <Widget>[
                        new Text(
                          .made_with,
                          style: new TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                        new Text(
                          .flutter,
                          style: new TextStyle(
                              fontSize: 22.0,
                              color: Theme.of(context).accentColor),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
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
                  /*

                        new FlatButton(onPressed: _launchFAQ, child: new Row(children: < Widget > [
                            new Container(child: new Icon(Icons.question_answer, color: Colors.green, size: 20.0, ), padding: EdgeInsets.all(5.0), ),
                            new Text(.faq, style: new TextStyle(color: Colors.green, fontSize: 20.0, ), ),
                        ], mainAxisAlignment: MainAxisAlignment.center, ), ),


                        new FlatButton(onPressed: _launchTOS, child: new Row(children: < Widget > [
                            new Container(child: new Icon(Icons.error, color: Colors.red, size: 20.0, ), padding: EdgeInsets.all(5.0), ),
                            new Text("Felhasználási feltételek", style: new TextStyle(color: Colors.red, fontSize: 20.0, ), ),
                        ], mainAxisAlignment: MainAxisAlignment.center, ), ),
                        new FlatButton(onPressed: _launchYoutubeURL, child: new Row(children: < Widget > [
                            new Container(child: new Icon(IconData(0xf5c3, fontFamily: "Material Design Icons"), color: Colors.red, size: 20.0, ), padding: EdgeInsets.all(5.0), ),
                            new Text(.youtube, style: new TextStyle(color: Colors.red, fontSize: 20.0, ), ),
                        ], mainAxisAlignment: MainAxisAlignment.center, ), ),
                        new FlatButton(onPressed: _launchTelegramURL, child: new Row(children: < Widget > [
                            new Container(child: new Icon(IconData(0xf501, fontFamily: "Material Design Icons"), color: Colors.blue, size: 20.0, ), padding: EdgeInsets.all(5.0), ),
                            new Text(.telegram, style: new TextStyle(color: Colors.blue, fontSize: 20.0, ), ),
                        ], mainAxisAlignment: MainAxisAlignment.center, )),
                        new FlatButton(onPressed: _launchGmailURL, child: new Row(children: < Widget > [
                            new Container(child: new Icon(IconData(0xf2ab, fontFamily: "Material Design Icons"), color: Colors.red, size: 20.0, ), padding: EdgeInsets.all(5.0), ),
                            new Text(.email, style: new TextStyle(color: Colors.red, fontSize: 20.0, ), ),
                        ], mainAxisAlignment: MainAxisAlignment.center, )),
                        new FlatButton(onPressed: _launchGithubURL, child: new Row(children: < Widget > [
                            new Container(child: new Icon(IconData(0xf2a4, fontFamily: "Material Design Icons"), color: Colors.black, size: 20.0, ), padding: EdgeInsets.all(5.0), ),
                            new Text(.github, style: new TextStyle(fontSize: 20.0, ), ),
                        ], mainAxisAlignment: MainAxisAlignment.center, )),
                        new FlatButton(onPressed: _launchInstagramURL, child: new Row(children: < Widget > [
                            new Container(child: new Icon(IconData(0xf2fe, fontFamily: "Material Design Icons"), color: Colors.pink, size: 20.0, ), padding: EdgeInsets.all(5.0), ),
                            new Text(.instagram, style: new TextStyle(color: Colors.pink, fontSize: 20.0, ), ),
                        ], mainAxisAlignment: MainAxisAlignment.center, )),
                      ű
                    */
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

  /*
    _launchFAQ() async {
        return showDialog < Null > (context: context, barrierDismissible: true, builder: (BuildContext context) {
            return new SimpleDialog(children: < Widget > [
                new SingleChildScrollView(child: Html(data: globals.htmlFAQ), ),
            ], title: Text(.faq), contentPadding: EdgeInsets.all(20), shape: RoundedRectangleBorder(side: BorderSide(style: BorderStyle.none, width: 1, ), borderRadius: BorderRadius.circular(3), ), );
        }, );
    }
    _launchYoutubeURL() async {
        const url = '';
        if (await canLaunch(url)) {
            await launch(url);
        } else {
            throw 'Could not launch $url';
        }
    }
    _launchTOS() async {
        const url = '';
        if (await canLaunch(url)) {
            await launch(url);
        } else {
            throw 'Could not launch $url';
        }
    }
    _launchTelegramURL() async {
        const url = '';
        if (await canLaunch(url)) {
            await launch(url);
        } else {
            throw 'Could not launch $url';
        }
    }
    _launchGmailURL() async {
        const url = '';
        if (await canLaunch(url)) {
            await launch(url);
        } else {
            throw 'Could not launch $url';
        }
    }
    _launchGithubURL() async {
        const url = '';
        if (await canLaunch(url)) {
            await launch(url);
        } else {
            throw 'Could not launch $url';
        }
    }
    _launchInstagramURL() async {
        const url = '';
        if (await canLaunch(url)) {
            await launch(url);
        } else {
            throw 'Could not launch $url';
        }
    }
    _behaveNicelyAgain() {
        globals.behaveNicely = true;
        Fluttertoast.showToast(msg: "Hiperhajtómű kikapcsolva.", backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
        RequestHelper().refreshAppSettings();
        Navigator.pushNamed(context, "/about");
    }
    */
  _popToLogin() {
    Navigator.pushNamed(context, "/login");
  }
}
