import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:filcnaplo/GlobalDrawer.dart';
import 'package:filcnaplo/Helpers/BackgroundHelper.dart';
import 'package:filcnaplo/Helpers/SettingsHelper.dart';
import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/Utils/ColorManager.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(new MaterialApp(home: new SettingsScreen()));
  BackgroundHelper().register();
}

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _isColor;
  bool _isDark;
  bool _amoled;
  bool _isNotification;
  bool _isLogo;
  bool _isSingleUser;
  bool _smartUserAgent;
  bool nextLesson;
  String _lang = "";
  static const LANG_LIST = {"hu": "Magyar", "en": "English", "de": "Deutsch"};
  final List<int> refreshArray = [15, 60, 90, 120, 360, 720];
  int _refreshNotification;
  int _theme;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  void _initSet() async {
    _isColor = await SettingsHelper().getColoredMainPage();
    _isDark = await SettingsHelper().getDarkTheme();
    _isNotification = await SettingsHelper().getNotification();
    _isLogo = await SettingsHelper().getLogo();
    _refreshNotification = await SettingsHelper().getRefreshNotification();
    _isSingleUser = await SettingsHelper().getSingleUser();
    _smartUserAgent = await SettingsHelper().getSmartUserAgent();
    _theme = await SettingsHelper().getTheme();
    _lang = await SettingsHelper().getLang();
    _amoled = await SettingsHelper().getAmoled();
    nextLesson = await SettingsHelper().getNextLesson();
    setState(() {});
  }

  @override
  void initState() {
    setState(() {
      _initSet();
    });
    BackgroundHelper().configure();
    super.initState();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> get canSyncOnData async =>
      await SettingsHelper().getCanSyncOnData();
  void _setNextLesson(bool value) async {
    setState(() {
      nextLesson = value;
    });
    SettingsHelper().setNextLesson(nextLesson);
    BackgroundHelper().cancelNextLesson();
  }

  void _setLang(String value) async {
    const Locale de = Locale("de", "DE");
    const Locale hu = Locale("hu", "HU");
    const Locale en = Locale("en", "US");

    _lang = value;
    globals.lang = value;
    SettingsHelper().setLang(_lang);

    const langs = {"en": en, "de": de, "hu": hu};
//    print(langs[value]);
    I18n.onLocaleChanged(langs[value]);
  }

  void _setAmoled(bool value) {
    setState(() {
      _amoled = value;
      SettingsHelper().setAmoled(_amoled);
    });
    globals.isAmoled = _amoled;
    DynamicTheme.of(context)
        .setThemeData(ColorManager().getTheme(Theme.of(context).brightness));
  }

  void _refreshNotificationChange(int value) async {
    setState(() {
      _refreshNotification = value;
      SettingsHelper().setRefreshNotification(_refreshNotification);
    });
    await BackgroundHelper().configure();
  }

  void _isLogoChange(bool value) {
    setState(() {
      _isLogo = value;
      globals.isLogo = value;
      SettingsHelper().setLogo(_isLogo);
    });
  }

  void _isColorChange(bool value) {
    setState(() {
      _isColor = value;
      globals.isColor = value;
      SettingsHelper().setColoredMainPage(_isColor);
    });
  }

  void _isNotificationChange(bool value) async {
    setState(() {
      _isNotification = value;
      SettingsHelper().setNotification(_isNotification);
    });
    await BackgroundHelper().configure();
    if (value) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
        Fluttertoast.showToast(
            msg: I18n.of(context).success,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }).catchError((e) {
        Fluttertoast.showToast(
            msg: I18n.of(context).notificationFailed,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _isDarkChange(bool value) async {
    setState(() {
      _isDark = value;
      SettingsHelper().setDarkTheme(_isDark);
    });
    globals.isDark = _isDark;
    await DynamicTheme.of(context)
        .setBrightness(value ? Brightness.dark : Brightness.light);
  }

  void _themChange(int value) {
    setState(() {
      _theme = value;
      SettingsHelper().setTheme(_theme);
    });
    globals.themeID = _theme;
    DynamicTheme.of(context)
        .setThemeData(ColorManager().getTheme(Theme.of(context).brightness));
    globals.CurrentTextColor =
        ColorManager().getTheme(Theme.of(context).brightness).accentColor;
//    print("CurrentTextColor: ");
    // print(globals.CurrentTextColor);
  }

  void _isSingleUserChange(bool value) {
    setState(() {
      _isSingleUser = value;
      globals.isSingle = value;
      SettingsHelper().setSingleUser(_isSingleUser);
    });
  }

  void _smartUserAgentChange(bool value) {
    setState(() {
      _smartUserAgent = value;
      globals.smartUserAgent = value;
      SettingsHelper().setSmartUserAgent(_smartUserAgent);
      RequestHelper().refreshAppSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    
    List<String> themes = [
      I18n.of(context).colorGreen,
      I18n.of(context).colorRed,
      I18n.of(context).colorBlue,
      I18n.of(context).colorLime,
      I18n.of(context).colorYellow,
      I18n.of(context).colorOrange,
      I18n.of(context).colorGrey,
      I18n.of(context).colorPink,
      I18n.of(context).colorPurple,
      I18n.of(context).colorTeal
    ];
    return new WillPopScope(
        onWillPop: () {
          globals.screen = 0;
          Navigator.pushReplacementNamed(context, "/main");
        },
        child: Scaffold(
          drawer: GDrawer(),
          appBar: new AppBar(
            title: new Text(I18n.of(context).settingsTitle),
          ),
          body: new Container(
            child: _isColor != null
                ? new ListView(
                    children: <Widget>[
                      SwitchListTile(
                        title: new Text(
                          I18n.of(context).settingsColorful,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        activeColor: Theme.of(context).accentColor,
                        value: _isColor,
                        onChanged: _isColorChange,
                        secondary: new Icon(IconData(0xf266,
                            fontFamily: "Material Design Icons")),
                      ),
                      SwitchListTile(
                        title: new Text(
                          I18n.of(context).settingsDarkTheme,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        activeColor: Theme.of(context).accentColor,
                        value: _isDark,
                        onChanged: _isDarkChange,
                        secondary: new Icon(IconData(0xf50e,
                            fontFamily: "Material Design Icons")),
                      ),
                      SwitchListTile(
                        title: new Text(
                          I18n.of(context).settingsAmoled,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        activeColor: Theme.of(context).accentColor,
                        value: _isDark ? _amoled : false,
                        onChanged: _isDark ? _setAmoled : null,
                        secondary: new Icon(IconData(0xf301,
                            fontFamily: "Material Design Icons")),
                      ),
                      SwitchListTile(
                        title: new Text(
                          I18n.of(context).settingsSmart,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        activeColor: Theme.of(context).accentColor,
                        value: _smartUserAgent,
                        onChanged: _smartUserAgentChange,
                        secondary: new Icon(IconData(0xfcbf,
                            fontFamily: "Material Design Icons")),
                      ),
                      ListTile(
                        title: new Text(
                          I18n.of(context).settingsEvaluationColors,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, "/evalcolor");
                        },
                        leading: new Icon(Icons.color_lens),
                      ),
                      ListTile(
                        title: new PopupMenuButton<int>(
                          child: new ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: new Text(
                              capitalize(I18n.of(context).color) +
                                  ": " +
                                  themes[_theme],
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          onSelected: _themChange,
                          itemBuilder: (BuildContext context) {
                            return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                                .map((int integer) {
                              return new PopupMenuItem<int>(
                                  value: integer,
                                  child: new Row(
                                    children: <Widget>[
                                      new Container(
                                        decoration: ShapeDecoration(
                                            shape: CircleBorder(),
                                            color: ColorManager()
                                                .getColorSample(integer)),
                                        height: 16,
                                        width: 16,
                                        margin: EdgeInsets.only(right: 4),
                                      ),
                                      new Text(themes[integer]),
                                    ],
                                  ));
                            }).toList();
                          },
                        ),
                        leading: new Icon(Icons.color_lens),
                      ),
                      SwitchListTile(
                        title: new Text(
                          I18n.of(context).settingsNotifications,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        activeColor: Theme.of(context).accentColor,
                        value: _isNotification,
                        onChanged: _isNotificationChange,
                        secondary: new Icon(IconData(0xf09a,
                            fontFamily: "Material Design Icons")),
                      ),
                      SwitchListTile(
                        title: new Text(
                          I18n.of(context).settingsNextLesson,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        value: nextLesson,
                        activeColor: Theme.of(context).accentColor,
                        onChanged: _isNotification ? _setNextLesson : null,
                        secondary: new Icon(Icons.access_time),
                      ),
                      _isNotification
                          ? new PopupMenuButton<int>(
                              child: new ListTile(
                                title: new Text(
                                  I18n.of(context).settingsSyncFrequency(
                                      _refreshNotification.toString()),
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                leading: new Icon(IconData(0xf4e6,
                                    fontFamily: "Material Design Icons")),
                              ),
                              onSelected: _refreshNotificationChange,
                              itemBuilder: (BuildContext context) {
                                return refreshArray.map((int integer) {
                                  return new PopupMenuItem<int>(
                                      value: integer,
                                      child: new Row(
                                        children: <Widget>[
                                          new Text(integer.toString() +
                                              " " +
                                              I18n.of(context).timeMinute),
                                        ],
                                      ));
                                }).toList();
                              },
                            )
                          : new ListTile(
                              title: new Text(
                                I18n.of(context).settingsSyncFrequency(
                                    _refreshNotification.toString()),
                                style: TextStyle(fontSize: 20.0),
                              ),
                              enabled: false,
                              leading: new Icon(IconData(0xf4e6,
                                  fontFamily: "Material Design Icons")),
                            ),
                      ListTile(
                        title: new Text(
                          I18n.of(context).settingsLanguage,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        trailing: new Container(
                          child: new DropdownButton<String>(
                            items: LANG_LIST.keys.map((String lang) {
                              String langName = LANG_LIST[lang];
                              return DropdownMenuItem<String>(
                                child: Text(
                                  langName,
                                  textAlign: TextAlign.end,
                                ),
                                value: lang,
                              );
                            }).toList(),
                            onChanged: _setLang,
                            value: _lang,
                          ),
                          height: 50,
                          width: 120,
                          alignment: Alignment(1, 0),
                        ),
                        leading: new Icon(IconData(0xf1e7,
                            fontFamily: "Material Design Icons")),
                      ),
                      new Divider(color: globals.isDark ? Colors.grey : Colors.black54),
                      !Platform.isIOS
                          ? new ListTile(
                              leading: new Icon(Icons.import_export),
                              title: new Text(
                                  I18n.of(context).export.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold)),
                              onTap: () {
                                Navigator.pushNamed(context, "/export");
                              },
                            )
                          : Container(),
                      new ListTile(
                        leading: new Icon(Icons.bug_report),
                        title: new Text(I18n.of(context).settingsBugreport.toUpperCase(),
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold)),
                        onTap: _openBugReport,
                      ),

                      new ListTile(
                          title: new Text(
                        capitalize(I18n.of(context).appVersion) +
                            ": " +
                            globals.version,
                        style: TextStyle(fontSize: 15.0),
                        textAlign: TextAlign.right,
                      ))
                    ],
                    padding: EdgeInsets.all(10),
                  )
                : new Container(),
          ),
        ));
  }
  _openBugReport() async {
    const url = "https://github.com/filcnaplo/filcnaplo/issues/new";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
