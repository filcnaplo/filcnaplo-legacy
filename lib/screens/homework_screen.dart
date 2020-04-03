import 'dart:async';

import 'package:filcnaplo/dialogs/add_homework_dialog.dart';
import 'package:filcnaplo/helpers/request_helper.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:filcnaplo/models/homework.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo/dialogs/select_time_dialog.dart';
import 'package:filcnaplo/global_drawer.dart';
import 'package:filcnaplo/helpers/homework_helper.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:html/parser.dart';


void main() {
  runApp(MaterialApp(home: HomeworkScreen()));
}

class HomeworkScreen extends StatefulWidget {
  @override
  HomeworkScreenState createState() => HomeworkScreenState();
}

class HomeworkScreenState extends State<HomeworkScreen> {
  List<User> users;

  bool hasLoaded = true;
  bool hasOfflineLoaded = false;

  List<Homework> homeworks = List();
  List<Homework> selectedHomework = List();

  @override
  void initState() {
    super.initState();
    _onRefreshOffline();
    _onRefresh(showErrors: false);
  }

  void refHomework() {
    setState(() {
      selectedHomework.clear();
    });

    for (Homework n in homeworks) {
      if (n.owner.id == globals.selectedUser.id) {
        setState(() {
          selectedHomework.add(n);
        });
      }
    }
  }

String htmlParser(String html) {
  var document = parse(html);
  return document.body.text;
}
  
  void launchurl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}



 void showSuccess(String msg) {
 Fluttertoast.showToast(
     msg: msg,
     backgroundColor: Colors.green,
     textColor: Colors.white,
     fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    return WillPopScope(
        onWillPop: () {
          globals.screen = 0;
          Navigator.pushReplacementNamed(context, "/home");
        },
        child: Scaffold(
            drawer: GlobalDrawer(),
            appBar: AppBar(
              title: Text(capitalize(I18n.of(context).homeworkTitle)),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () {
                    timeDialog().then((b) {
                      _onRefreshOffline();
                      refHomework();
                      _onRefresh();
                      refHomework();
                    });
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _openChooser,
              child: Icon(Icons.add, color: Colors.white),
            ),
            body: Container(
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
                                  itemCount: selectedHomework.length,
                                ),
                                onRefresh: _onRefresh)),
                      ])
                    : Center(child: CircularProgressIndicator()))));
  }

  Future<bool> _openChooser() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return ChooseLessonDialog();
        });
  }

  Future<bool> timeDialog() {
    return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return TimeSelectDialog();
          },
        ) ??
        false;
  }

  Future<Null> homeworksDialog(Homework homework) async {
    if (homework.deletedBy > 0) {
      homework.text = "<strike>${homework.text}</strike>";
    }

    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(homework.subject + " " + I18n.of(context).homework),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                homework.deadline != null
                    ? Text(capitalize(I18n.of(context).homeworkDeadline) +
                        ": " +
                        stringdateToHuman(homework.deadline))
                    : Container(),
                Text(capitalize(I18n.of(context).homeworkSubject) +
                    ": " +
                    homework.subject),
                Text(capitalize(I18n.of(context).homeworkUploadUser) +
                    ": " +
                    homework.uploader),
                Text(capitalize(I18n.of(context).homeworkUploadTime) +
                    ": " +
                    homework.uploadDate
                        .substring(0, 11)
                        .replaceAll("-", '. ')
                        .replaceAll("T", ". ")),
                Divider(
                  height: 4.0,
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                ),
                Html(data: HtmlUnescape().convert(homework.text), onLinkTap: (url) {launchurl(url);}),
              ],
            ),
          ),
          actions: <Widget>[  
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                RequestHelper()
                    .deleteHomework(homework.id, globals.selectedUser);
              },
            ),
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: htmlParser(HtmlUnescape().convert(homework.text)).toString())).then((result) {
                  showSuccess(I18n.of(globals.context).successHomeworkCopy);
              });},
            ),
            IconButton(
              icon: Text(I18n.of(context).dialogOk.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

 
  Future<Null> _onRefresh({bool showErrors = true}) async {
    setState(() {
      hasLoaded = false;
    });
    Completer<Null> completer = Completer<Null>();
    List<Homework> homeworksNew = await HomeworkHelper().getHomeworks(
        globals.timeData[globals.selectedTimeForHomework], showErrors);
    if (homeworksNew.length > homeworks.length) homeworks = homeworksNew;
    homeworks
        .sort((Homework a, Homework b) => b.uploadDate.compareTo(a.uploadDate));
    if (mounted)
      setState(() {
        refHomework();
        hasLoaded = true;
        hasOfflineLoaded = true;
        completer.complete();
      });
    return completer.future;
  }

  Future<Null> _onRefreshOffline() async {
    setState(() {
      hasOfflineLoaded = false;
    });
    Completer<Null> completer = Completer<Null>();
    homeworks = await HomeworkHelper()
        .getHomeworksOffline(globals.timeData[globals.selectedTimeForHomework]);
    homeworks
        .sort((Homework a, Homework b) => b.uploadDate.compareTo(a.uploadDate));
    if (mounted)
      setState(() {
        refHomework();
        hasOfflineLoaded = true;
        completer.complete();
      });
    return completer.future;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        
         GestureDetector(
      onTap: (){ homeworksDialog(selectedHomework[index]);},
      child:
        Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            style: BorderStyle.none,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        margin: EdgeInsets.all(6.0),
        color: globals.isColor
            ?  Colors.blue[600]
            : globals.isDark ? Color.fromARGB(255, 25, 25, 25) : Colors.white,
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Text(
                  selectedHomework[index].subject,
                  style: TextStyle(
                      fontSize: 21.0,
                      color: globals.isColor
                              ? Colors.white
                              : globals.isDark
                                 ?Colors.white
                                 :Colors.black, 
                      fontWeight: FontWeight.bold),
                ),
                margin: EdgeInsets.all(10.0),
              ),
              Container(
                child: Text(htmlParser(HtmlUnescape().convert(selectedHomework[index].text)),
                    maxLines: 4,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 17.0,
                        color: globals.isColor
                            ? Colors.white
                            : globals.isDark ? Colors.white : Colors.black)),
                padding: EdgeInsets.all(10.0),
              ),
                
              Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        style: BorderStyle.none,
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: globals.isDark
                        ? Color.fromARGB(255, 25, 25, 25)
                        : Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: 
                     Row(
                      children: <Widget>[
                        Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left:  2),
                          child: Text(selectedHomework[index].uploader, overflow: TextOverflow.ellipsis)
                            
                          ),),
                        Flexible(
                                fit: FlexFit.loose,
                                child: Container(
                                child: Text( 
                              stringdateToHuman(selectedHomework[index].uploadDate),
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: globals.isDark
                                            ? Colors.white
                                            : Colors.grey[900])),
                                alignment: Alignment(1.0, 0.0),
                              ))

                      ],
                    ),
                  )),
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(
                color: globals.isColor
                    ? Colors.blue[600]
                    : globals.isDark
                        ? Color.fromARGB(255, 25, 25, 25)
                        : Colors.white,
                width: 2.5),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
      )
     )],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    selectedHomework.clear();
    super.dispose();
  }
}
