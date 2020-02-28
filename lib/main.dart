import 'dart:math';

import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/screens/messageScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info/package_info.dart';

import 'Datas/Account.dart';
import 'Datas/User.dart';

import 'Helpers/BackgroundHelper.dart';
import 'Helpers/DBHelper.dart';
import 'Helpers/RequestHelper.dart';
import 'Helpers/SettingsHelper.dart';
import 'Helpers/encrypt_codec.dart';

import 'Utils/AccountManager.dart';
import 'Utils/ColorManager.dart';
import 'Utils/Saver.dart' as Saver;

import 'globals.dart' as globals;

import 'screens/absentsScreen.dart';
import 'screens/accountsScreen.dart';
import 'screens/evaluationColorSettingsScreen.dart';
import 'screens/evaluationsScreen.dart';
import 'screens/exportScreen.dart';
import 'screens/homeworkScreen.dart';
import 'screens/importScreen.dart';
import 'screens/mainScreen.dart';
import 'screens/notesScreen.dart';
import 'screens/settingsScreen.dart';
import 'screens/studentScreen.dart';
import 'screens/timeTableScreen.dart';
import 'screens/testsScreen.dart';
import 'screens/loginScreen.dart';

bool isNew = true;

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final i18n = I18n.delegate;

  @override
  void initState() {
    super.initState();
    I18n.onLocaleChanged = onLocaleChange;
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      I18n.locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Locale de = Locale("de", "DE");
    const Locale hu = Locale("hu", "HU");
    const Locale en = Locale("en", "US");
    var langs = {"en": en, "de": de, "hu": hu};
//    print(langs[globals.lang]);
    I18n.onLocaleChanged(langs[globals.lang]);

    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ColorManager().getTheme(brightness),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            localizationsDelegates: [
              i18n,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: i18n.supportedLocales,
            localeResolutionCallback:
                i18n.resolution(fallback: new Locale("hu", "HU")),
            onGenerateTitle: (BuildContext context) =>
                I18n.of(context).appTitle,
            title: "Filc Napló",
            theme: theme,
            routes: <String, WidgetBuilder>{
              '/main': (_) => new MainScreen(),
              '/login': (_) => new LoginScreen(),
              '/timetable': (_) => new TimeTableScreen(),
              '/homework': (_) => new HomeworkScreen(),
              '/notes': (_) => new NotesScreen(),
              '/messages': (_) => new MessageScreen(),
              '/absents': (_) => new AbsentsScreen(),
              '/accounts': (_) => new AccountsScreen(),
              '/settings': (_) => new SettingsScreen(),
              '/evaluations': (_) => new EvaluationsScreen(),
              '/export': (_) => new ExportScreen(),
              '/import': (_) => new ImportScreen(),
              '/evalcolor': (_) => new colorSettingsScreen(),
              '/student': (_) => new StudentScreen(),
              '/tests': (_) => new TestsScreen(),
            },
            navigatorKey: navigatorKey,
            home: isNew ? new LoginScreen() : MainScreen(),
          );
        });
  }
}

void main({bool noReset = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!noReset) {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: "db_key");
    if (value == null) {
      int randomNumber = Random.secure().nextInt(4294967296);
      await storage.write(key: "db_key", value: randomNumber.toString());
      value = await storage.read(key: "db_key");
    }

    var codec = getEncryptSembastCodec(password: value);

    globals.db = await globals.dbFactory.openDatabase(
        (await DBHelper().localFolder) + DBHelper().dbPath,
        codec: codec);
  }
  if (await Saver.shouldMigrate) {
    Saver.migrate();
  } else {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    globals.version = packageInfo.version;
    globals.isBeta = globals.version.startsWith("b");
    List<User> users = await AccountManager().getUsers();
    isNew = (users.isEmpty);
    globals.isLogo = await SettingsHelper().getLogo();
    globals.isSingle = await SettingsHelper().getSingleUser();
    globals.smartUserAgent = await SettingsHelper().getSmartUserAgent();
    globals.lang = await SettingsHelper().getLang();
    RequestHelper().refreshAppSettings();

    if (!isNew) {
      BackgroundHelper().register();

      globals.isDark = await SettingsHelper().getDarkTheme();
      globals.isAmoled = await SettingsHelper().getAmoled();
      globals.isColor = await SettingsHelper().getColoredMainPage();
      globals.isSingle = await SettingsHelper().getSingleUser();
      globals.multiAccount = (await Saver.readUsers()).length != 1;
      if (!noReset) globals.users = users;
      if (!noReset) globals.accounts = List();
      if (!noReset)
        for (User user in users) globals.accounts.add(Account(user));
      if (!noReset) globals.selectedAccount = globals.accounts[0];
      if (!noReset) globals.selectedUser = users[0];
      globals.themeID = await SettingsHelper().getTheme();
      globals.CurrentTextColor = await ColorManager().getTheme(0).accentColor;
      globals.color1 = await SettingsHelper().getEvalColor(0);
      globals.color2 = await SettingsHelper().getEvalColor(1);
      globals.color3 = await SettingsHelper().getEvalColor(2);
      globals.color4 = await SettingsHelper().getEvalColor(3);
      globals.color5 = await SettingsHelper().getEvalColor(4);

      globals.showCardType = await SettingsHelper().getShowCardType();
    }

    runApp(MyApp());
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }
}

Future<void> reInit() async {
  runApp(MyApp());
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

void backgroundFetchHeadlessTask() async {
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('notification_icon');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await BackgroundHelper().backgroundTask().then((int finished) {
    BackgroundFetch.finish();
  });
}
