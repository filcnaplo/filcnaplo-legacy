import 'dart:math';

import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/screens/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/services.dart';

import 'package:filcnaplo/models/account.dart';
import 'package:filcnaplo/models/user.dart';

import 'package:filcnaplo/helpers/background_helper.dart';
import 'package:filcnaplo/helpers/database_helper.dart';
import 'package:filcnaplo/helpers/request_helper.dart';
import 'package:filcnaplo/helpers/settings_helper.dart';
import 'package:filcnaplo/helpers/encrypt_codec.dart';

import 'package:filcnaplo/utils/account_manager.dart';
import 'package:filcnaplo/utils/color_manager.dart';
import 'package:filcnaplo/utils/saver.dart' as Saver;

import 'globals.dart' as globals;

import 'package:filcnaplo/screens/absents_screen.dart';
import 'package:filcnaplo/screens/accounts_screen.dart';
import 'package:filcnaplo/screens/evaluation_colors_screen.dart';
import 'package:filcnaplo/screens/evaluations_screen.dart';
import 'package:filcnaplo/screens/export_screen.dart';
import 'package:filcnaplo/screens/homework_screen.dart';
import 'package:filcnaplo/screens/import_screen.dart';
import 'package:filcnaplo/screens/home_screen.dart';
import 'package:filcnaplo/screens/notes_screen.dart';
import 'package:filcnaplo/screens/settings_screen.dart';
import 'package:filcnaplo/screens/student_screen.dart';
import 'package:filcnaplo/screens/timetable_screen.dart';
import 'package:filcnaplo/screens/tests_screen.dart';
import 'package:filcnaplo/screens/login_screen.dart';

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
    globals.context = context;

    const Locale de = Locale("de", "DE");
    const Locale hu = Locale("hu", "HU");
    const Locale en = Locale("en", "US");
    var langs = {"en": en, "de": de, "hu": hu};
    I18n.onLocaleChanged(langs[globals.lang]);

    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ColorManager().getTheme(brightness),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            localizationsDelegates: [
              i18n,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: i18n.supportedLocales,
            localeResolutionCallback:
                i18n.resolution(fallback: Locale("hu", "HU")),
            onGenerateTitle: (BuildContext context) =>
                I18n.of(context).appTitle,
            title: "Filc Napló",
            theme: theme,
            routes: <String, WidgetBuilder>{
              '/home': (_) => HomeScreen(),
              '/login': (_) => LoginScreen(),
              '/timetable': (_) => TimeTableScreen(),
              '/homework': (_) => HomeworkScreen(),
              '/notes': (_) => NotesScreen(),
              '/messages': (_) => MessageScreen(),
              '/absents': (_) => AbsentsScreen(),
              '/accounts': (_) => AccountsScreen(),
              '/settings': (_) => SettingsScreen(),
              '/evaluations': (_) => EvaluationsScreen(),
              '/export': (_) => ExportScreen(),
              '/import': (_) => ImportScreen(),
              '/evalcolor': (_) => colorSettingsScreen(),
              '/student': (_) => StudentScreen(),
              '/tests': (_) => TestsScreen(),
            },
            navigatorKey: navigatorKey,
            home: isNew ? LoginScreen() : HomeScreen(),
          );
        });
  }
}

void main({bool noReset = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!noReset) {
    final storage = FlutterSecureStorage();
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
    globals.isBeta = globals.version.endsWith("-beta");
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

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) => {runApp(MyApp())});
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }
}

Future<void> reInit() async {
  runApp(MyApp());
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void backgroundFetchHeadlessTask() async {
  var initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await BackgroundHelper().backgroundTask().then((int finished) {
    BackgroundFetch.finish();
  });
}
