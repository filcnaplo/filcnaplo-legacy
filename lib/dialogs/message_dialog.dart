import 'package:filcnaplo/helpers/request_helper.dart';
import 'package:filcnaplo/models/attachment.dart';
import 'package:filcnaplo/models/message.dart';
import 'package:filcnaplo/helpers/message_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/globals.dart' as globals;

import 'package:url_launcher/url_launcher.dart';

class MessageDialog extends StatefulWidget {
  const MessageDialog(this.message);
  final Message message;

  @override
  MessageDialogState createState() => MessageDialogState();
}

class MessageDialogState extends State<MessageDialog> {
  Message currentMessage;

  @override
  void initState() {
    super.initState();
    currentMessage = widget.message;
    MessageHelper()
        .getMessageByIdOffline(globals.selectedAccount.user, currentMessage.id)
        .then((Message message) {
      if (message != null) {
        setState(() {
          currentMessage = message;
        });
      }
      MessageHelper()
          .getMessageById(globals.selectedAccount.user, currentMessage.id)
          .then((Message message) {
        if (message != null) {
          setState(() {
            currentMessage = message;
          });
        }
      });
    });
  }

  Widget build(BuildContext context) {
    List<Widget> attachments = [];

    currentMessage.attachments.forEach((att) {
      print(att.fileName);
      if (att.fileName != null) {
        attachments.add(
          Row(children: <Widget>[
            Flexible(
                child: Text(
              att.fileName,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            )),
            IconButton(
              icon: Icon(
                Icons.get_app,
                color: Colors.blue,
              ),
              onPressed: () {
                MessageHelper()
                    .downloadAttachment(globals.selectedAccount.user, att);
              },
            ),
          ]),
        );
      }
    });

    return SimpleDialog(
      title: Text(currentMessage.subject),
      titlePadding: EdgeInsets.all(15),
      contentPadding: const EdgeInsets.all(15.0),
      children: <Widget>[
        Container(
          child: Text(
            capitalize(I18n.of(context).messageReceivers) +
                ": " +
                currentMessage.receivers.join(", ") +
                "\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          child: Html(data: HtmlUnescape().convert(currentMessage.text), onLinkTap: (url) {_launchUrl(url);},),
        ),
        Container(
          child: Text(
            currentMessage.senderName,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Container(
          child: Column(
              children: (attachments == null) ? <Widget>[] : attachments),
        ),
      ],
    );
  }

  void _launchUrl(url) async {
    if (await canLaunch(url)) await launch(url);
  }
}
