import 'dart:async';

import 'package:filcnaplo/models/message.dart';
import 'package:filcnaplo/dialogs/message_dialog.dart';
import 'package:filcnaplo/helpers/request_helper.dart';
import 'package:filcnaplo/screens/screen.dart';
import 'package:flutter/material.dart';

import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/globals.dart' as globals;

void main() {
  runApp(MaterialApp(home: MessageScreen()));
}

class MessageScreen extends StatefulWidget {
  @override
  MessageScreenState createState() => MessageScreenState();
}

class MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    super.initState();
    _onRefresh(showErrors: false);
  }

  List<Message> get messages => globals.selectedAccount.messages;

  bool hasOfflineLoaded = true;
  bool hasLoaded = true;

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    return Screen(
        Text(I18n.of(context).messageTitle),
        Container(
            child: hasOfflineLoaded & (messages != null)
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
                            itemCount: messages.length,
                          ),
                          onRefresh: _onRefresh),
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

    hasLoaded = true;

    if (mounted) setState(() => completer.complete());
    return completer.future;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Widget sep = Container();

    return Column(
      children: <Widget>[
        sep,
        Divider(
          height: index != 0 ? 2.0 : 0.0,
        ),
        ListTile(
          //leading: Container(),
          title: Text(
            messages[index].subject,
          ),
          subtitle: Text(
            messages[index].senderName,
          ),
          trailing: Column(
            children: <Widget>[
              Text(
                dateToHuman(messages[index].date),
              ),
              Text(
                dateToWeekDay(messages[index].date, context),
              ),
            ],
          ),
          onTap: () {
            if (!messages[index].seen) {
              setState(() {
                messages[index].seen = true;
                RequestHelper().seeMessage(
                    messages[index].id, globals.selectedAccount.user);
              });
            }
            return showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    return MessageDialog(messages[index]);
                  },
                ) ??
                false;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    MessageScreenState().deactivate();
  }
}
