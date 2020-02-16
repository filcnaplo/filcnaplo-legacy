import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/globals.dart' as globals;

class NewHomeworkDialog extends StatefulWidget {
  const NewHomeworkDialog(this.lesson);
  final Lesson lesson;

  @override
  NewHomeworkDialogState createState() => new NewHomeworkDialogState();
}

class NewHomeworkDialogState extends State<NewHomeworkDialog> {
  String homework;

  Widget build(BuildContext context) {
    return new SimpleDialog(
<<<<<<< Updated upstream
      title: new Text(I18n.of(context).homework),
=======
      title: new Text(.homework),
>>>>>>> Stashed changes
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        new TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 10,
          onChanged: (String text) {
            homework = text;
          },
        ),
        MaterialButton(
<<<<<<< Updated upstream
          child: Text(I18n.of(context).dialogOk),
=======
          child: Text(.ok),
>>>>>>> Stashed changes
          onPressed: () {
            RequestHelper().uploadHomework(
                homework, widget.lesson, globals.selectedAccount.user);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
