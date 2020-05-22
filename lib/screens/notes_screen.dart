import 'dart:async';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';


import 'package:filcnaplo/models/note.dart';
import 'package:filcnaplo/screens/screen.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/globals.dart' as globals;

void main() {
  runApp(MaterialApp(home: NotesScreen()));
}

class NotesScreen extends StatefulWidget {
  @override
  NotesScreenState createState() => NotesScreenState();
}

class NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    _onRefreshOffline();
    _onRefresh(showErrors: false);
  }

  bool hasOfflineLoaded = false;
  bool hasLoaded = true;

  List<Note> notes = List();

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    //! For testing
    /* notes.add(Note(0, "tipus", "cim", """Lórum ipse, a lens relső irát lesz a csapacs, ma diste érés.
A bűnösség ercéjekor vagy láskas után, bántot kell csegergelnie, úgy hogy az üzetes mara csak a saját kézete badásába kodázhatja el a vergőt. A dülés kisményére a gyakmácsoknak önállóan kell tárványba pozniuk, és szabadon fenyékedhetnek.
A láskas akkor feres, ha a vergő nált tünembészével a plás mögé pirkol. https://filcnaplo.hu A fürt az, aki több láskast lötyögt. Ványos esetén a ' hirtelen sirzsok ' vons hatos. Ekkor a bűnösség maximum három szatáttal mozgós meg.
Szolán mara először korít láskast ez alatt a melás alatt, az lesz a kalkozás. filcnaplo.hu@gmail.com
    """, "Kovács Tanár", DateTime.now(), "2001-01-01"));
    printContents(); */
    return Screen(
        Text(capitalize(I18n.of(context).noteTitle)),
        Container(
            child: hasOfflineLoaded
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
                          itemCount: notes.length,
                        ),
                        onRefresh: _onRefresh,
                      ),
                    ),
                  ])
                : Center(child: CircularProgressIndicator())),
        "/home",
        <Widget>[]);
  }

  Future<Null> _onRefresh({bool showErrors = true}) async {
    setState(() {
      hasLoaded = false;
    });
    Completer<Null> completer = Completer<Null>();

    await globals.selectedAccount.refreshStudentString(false, showErrors);
    notes = globals.selectedAccount.notes;

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

    globals.selectedAccount.refreshStudentString(true, false);
    notes = globals.selectedAccount.notes;

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
          title: notes[index].title != null && notes[index].title != ""
              ? Text(
                  notes[index].title,
                  style: TextStyle(fontSize: 22),
                )
              : null,
          subtitle: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              child: Linkify(
                text: notes[index].content.replaceAll("\r", ""),
                linkStyle: TextStyle(fontSize: 16, color: Colors.blue),
                style: TextStyle(fontSize: 16),
                onOpen: (link) {_launchUrl(link.url);},
                options: LinkifyOptions(humanize: false),
              ),
            ),
            Container(
              child: Text(dateToHuman(notes[index].date) +
                  dateToWeekDay(notes[index].date, context)),
              alignment: Alignment(1, -1),
            ),
            notes[index].teacher != null
                ? Container(
                    child: Text(notes[index].teacher),
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
//! For testing
  /* void printContents() async {
    for (var note in notes) {
      await debugPrint(note.content, wrapWidth: 999999999999);
    }
  } */

  void _launchUrl(url) async {
    if (await canLaunch(url)) await launch(url);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
