import 'dart:async';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'package:filcnaplo/models/test.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/globals.dart' as globals;

void main() {
  runApp(MaterialApp(home: TestsScreen()));
}

class TestsScreen extends StatefulWidget {
  @override
  TestsScreenState createState() => TestsScreenState();
}

class TestsScreenState extends State<TestsScreen> {
  @override
  void initState() {
    super.initState();
    _onRefreshOffline();
    _onRefresh(showErrors: false);
  }

  bool hasOfflineLoaded = false;
  bool hasLoaded = true;

  List<Test> tests = List();

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    return Screen(
        Text(I18n.of(context).testTitle),
        Container(
            child: (hasOfflineLoaded && tests != null)
                ? Column(children: <Widget>[
                    !hasLoaded
                        ? Container(
                            child: LinearProgressIndicator(
                              value: null,
                            ),
                            height: 3,
                          )
                        : Container(
                            height: 3,
                          ),
                    Expanded(
                      child: RefreshIndicator(
                        child: ListView.builder(
                          itemBuilder: _itemBuilder,
                          itemCount: tests.length,
                        ),
                        onRefresh: _onRefresh,
                      ),
                    ),
                  ])
                : Center(child: CircularProgressIndicator())),
        "/home",
        <Widget>[]);
  }

  Future<Null> _onRefresh({bool showErrors}) async {
    setState(() {
      hasLoaded = false;
    });
    Completer<Null> completer = Completer<Null>();

    try {
      await globals.selectedAccount.refreshTests(false, showErrors);
      tests = globals.selectedAccount.tests;
      tests.sort((Test a, Test b) => b.creationDate.compareTo(a.creationDate));
    } catch (e) {
      print("[E] testScreen.onRefresh()0: " + e.toString());
    }

    hasLoaded = true;
    if (mounted)
      setState(() {
        completer.complete();
      });
    return completer.future;
  }

  Future<Null> _onRefreshOffline() async {
    setState(() {
      hasOfflineLoaded = false;
    });
    Completer<Null> completer = Completer<Null>();

    await globals.selectedAccount.refreshTests(true, false);
    tests = globals.selectedAccount.tests;

    hasOfflineLoaded = true;
    if (mounted)
      setState(() {
        completer.complete();
      });
    return completer.future;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        ListTile(
          title: tests[index].title != null && tests[index].title != ""
              ? Text(
                  tests[index].title,
                  style: TextStyle(fontSize: 22),
                )
              : null,
          subtitle: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              child: Text(
                tests[index].subject + " " + tests[index].mode,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Container(
              child: Text(dateToHuman(tests[index].date) +
                  dateToWeekDay(tests[index].date, context)),
              alignment: Alignment(1, -1),
            ),
            tests[index].teacher != null
                ? Container(
                    child: Text(tests[index].teacher),
                    alignment: Alignment(1, -1),
                  )
                : Container(),
          ]),
          isThreeLine: true,
        ),
        Divider(
          height: 10.0,
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
