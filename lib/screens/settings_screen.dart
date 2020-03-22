import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/global_drawer.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/helpers/background_helper.dart';
import 'package:filcnaplo/helpers/request_helper.dart';
import 'package:filcnaplo/helpers/settings_helper.dart';
import 'package:filcnaplo/utils/color_manager.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(home: SettingsScreen()));
}

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
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
  static const Map<String, String> LANG_LIST = {
    "hu": "Magyar",
    "en": "English",
    "de": "Deutsch"
  };
  final List<int> refreshArray = [15, 60, 90, 120, 360, 720];
  int _refreshNotification;
  int _theme;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
        AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
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
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            content: Text(
              I18n.of(context).success,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            )));
      }).catchError((e) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            content: Text(
              I18n.of(context).notificationFailed,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            )));
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
    return WillPopScope(
        onWillPop: () {
          globals.screen = 0;
          Navigator.pushReplacementNamed(context, "/home");
        },
        child: Scaffold(
          key: _scaffoldKey,
          drawer: GlobalDrawer(),
          appBar: AppBar(
            title: Text(I18n.of(context).settingsTitle),
          ),
          body: Container(
            child: _isColor != null
                ? ListView(
                    children: <Widget>[
                      MySwitchListTile(
                        text: I18n
                            .of(context)
                            .settingsColorful,
                        icon: IconData(0xf266,
                            fontFamily: "Material Design Icons"),
                        value: _isColor,
                        onChanged: _isColorChange,
                      ),
                      MySwitchListTile(
                        text: I18n
                            .of(context)
                            .settingsDarkTheme,
                        icon: IconData(
                            0xf50e, fontFamily: "Material Design Icons"),
                        value: _isDark,
                        onChanged: _isDarkChange,
                      ),
                      MySwitchListTile(
                        text: I18n
                            .of(context)
                            .settingsAmoled,
                        icon: IconData(
                            0xf301, fontFamily: "Material Design Icons"),
                        value: _isDark ? _amoled : false,
                        onChanged: _isDark ? _setAmoled : null,
                      ),
                      MySwitchListTile(
                        text: I18n
                            .of(context)
                            .settingsSmart,
                        icon: IconData(
                            0xfcbf, fontFamily: "Material Design Icons"),
                        value: _smartUserAgent,
                        onChanged: _smartUserAgentChange,
                      ),
                      ListTile(
                        title: Text(
                          I18n.of(context).settingsEvaluationColors,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, "/evalcolor");
                        },
                        leading: Icon(Icons.color_lens),
                      ),
                      ListTile(
                        title: PopupMenuButton<int>(
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(
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
                              return PopupMenuItem<int>(
                                  value: integer,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        decoration: ShapeDecoration(
                                            shape: CircleBorder(),
                                            color: ColorManager()
                                                .getColorSample(integer)),
                                        height: 16,
                                        width: 16,
                                        margin: EdgeInsets.only(right: 4),
                                      ),
                                      Text(themes[integer]),
                                    ],
                                  ));
                            }).toList();
                          },
                        ),
                        leading: Icon(Icons.color_lens),
                      ),
                      MySwitchListTile(
                        text: I18n
                            .of(context)
                            .settingsNotifications,
                        icon: IconData(
                            0xf09a, fontFamily: "Material Design Icons"),
                        value: _isNotification,
                        onChanged: _isNotificationChange,
                      ),
                      MySwitchListTile(
                        text: I18n
                            .of(context)
                            .settingsNextLesson,
                        icon: Icons.access_time,
                        value: nextLesson,
                        onChanged: _isNotification ? _setNextLesson : null,
                      ),
                      _isNotification
                          ? PopupMenuButton<int>(
                              child: ListTile(
                                title: Text(
                                  I18n.of(context).settingsSyncFrequency(
                                      _refreshNotification.toString()),
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                leading: Icon(IconData(0xf4e6,
                                    fontFamily: "Material Design Icons")),
                              ),
                              onSelected: _refreshNotificationChange,
                              itemBuilder: (BuildContext context) {
                                return refreshArray.map((int integer) {
                                  return PopupMenuItem<int>(
                                      value: integer,
                                      child: Row(
                                        children: <Widget>[
                                          Text(integer.toString() +
                                              " " +
                                              I18n.of(context).timeMinute),
                                        ],
                                      ));
                                }).toList();
                              },
                            )
                          : ListTile(
                              title: Text(
                                I18n.of(context).settingsSyncFrequency(
                                    _refreshNotification.toString()),
                                style: TextStyle(fontSize: 20.0),
                              ),
                              enabled: false,
                              leading: Icon(IconData(0xf4e6,
                                  fontFamily: "Material Design Icons")),
                            ),
                      ListTile(
                        title: Text(
                          I18n.of(context).settingsLanguage,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        trailing: Container(
                          child: DropdownButton<String>(
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
                        leading: Icon(IconData(0xf1e7,
                            fontFamily: "Material Design Icons")),
                      ),
                      Divider(
                          color: globals.isDark ? Colors.grey : Colors.black54),
                      !Platform.isIOS
                          ? ListTile(
                              leading: Icon(Icons.import_export),
                              title: Text(I18n.of(context).export.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold)),
                              onTap: () {
                                Navigator.pushNamed(context, "/export");
                              },
                            )
                          : Container(),
                      ListTile(
                        leading: Icon(Icons.bug_report),
                        title: Text(
                            I18n.of(context).settingsBugreport.toUpperCase(),
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold)),
                        onTap: _openBugReport,
                      ),
                      ListTile(
                          title: Text(
                        capitalize(I18n.of(context).appVersion) +
                            ": " +
                            globals.version,
                        style: TextStyle(fontSize: 15.0),
                        textAlign: TextAlign.right,
                      ))
                    ],
                    padding: EdgeInsets.all(10),
                  )
                : Container(),
          ),
        ));
  }

  _openBugReport() async {
    const url = "https://github.com/filcnaplo/filcnaplo/issues/new/choose";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class MySwitchListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool value;
  final Function onChanged;

  MySwitchListTile({this.text, this.icon, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        text,
        style: TextStyle(fontSize: 20.0),
      ),
      activeColor: Theme
          .of(context)
          .accentColor,
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
    );
  }
}