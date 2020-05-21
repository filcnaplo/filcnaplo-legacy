import 'dart:convert' show json;
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/helpers/database_helper.dart';
import 'package:filcnaplo/helpers/settings_helper.dart';
import 'package:filcnaplo/helpers/timetable_helper.dart';
import 'package:filcnaplo/models/account.dart';
import 'package:filcnaplo/models/user.dart';
import "package:filcnaplo/screens/screen.dart";
import 'package:filcnaplo/utils/saver.dart' as Saver;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MaterialApp(home: ExportScreen()));

class ExportScreen extends StatefulWidget {
  @override
  ExportScreenState createState() => ExportScreenState();
}

class ExportScreenState extends State<ExportScreen> {
  @override
  void initState() {
    super.initState();
    setState(() {
      init();
    });
  }

  void init() async {
    rootPath = (await getExternalStorageDirectory()).path;
    updateURL();
  }

  //region final variables
  final TextEditingController controller = TextEditingController();
  String rootPath; //nemtom hogy ez hogy legyen final

  List<String> get exportOptions => [
        I18n.of(context).exportGrades,
        I18n.of(context).exportLessons,
        I18n.of(context).exportAccounts
  ]; // a sorrend változtatása a hibás működéshez vezet!
  final List<String> formatOptions = [
    "JSON",
    "CSV"
  ]; // a sorrend változtatása a hibás működéshez vezet!
  final List<String> formats = [
    ".json",
    ".csv"
  ]; // a sorrend változtatása a hibás működéshez vezet!
  //endregion
  //region operation varriables
  String fullPath;
  User selectedUser = globals.users[0];
  int selectedData = 0;
  int selectedFormat = 0;
  String selectedDate;
  List<DateTime> pickedDate;

  //endregion

  void updateURL() {
    setState(() {
      String filename;
      switch (selectedData) {
        case 0:
          filename = "/grades-" + selectedUser.name;
          break;
        case 1:
          filename = "/lessons-" + selectedUser.name;
          break;
        case 2:
          selectedFormat = 0; //json
          filename = "/users";
          break;
      }
      fullPath =
          rootPath + filename.replaceAll(' ', '_') + formats[selectedFormat];
      controller.text = fullPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (globals.exportScreenToShowDeleteDB) selectedData = 2; //If coming from DB help popup
    return Screen(
        Text(I18n.of(context).export),
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  globals.exportScreenToShowDeleteDB
                  ? Text("""ADATBÁZISTÖRLŐ-MÓD

Először exportáld a fiókjaidat, hogy ne kelljen újból bejelentkezned. Ne változtass a fájl mentési helyén vagy formátumán.
Az exportálás után ebben a módban törlődik az adatbázis, majd bezár az app.
Ezután nyisd meg újra, és a bejelentkező képernyőn válaszd az "Importálás"-t.
                  """,
                  textAlign: TextAlign.start,)
                  : Container(),
                  globals.exportScreenToShowDeleteDB
                  ? RaisedButton(
                    onPressed: () {
                      globals.exportScreenToShowDeleteDB = false;
                      selectedData = 0;
                      setState(() {});
                    },
                    color: Theme.of(context).accentColor,
                    child: Text(
                      "Kilépés az adatbázistörlő-módból",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                  : Container(),
                  DropdownButton(
                    items: exportOptions.map((String exportData) {
                      return DropdownMenuItem(
                        child: Text(exportData),
                        value: exportData,
                      );
                    }).toList(),
                    onChanged: (exportData) async {
                      selectedData = exportOptions.indexOf(exportData);
                      updateURL();
                    },
                    value: exportOptions[selectedData],
                  ),
                  dinamicWidget(selectedData),
                  TextField(
                    onChanged: (text) {
                      fullPath = text;
                    },
                    controller: controller,
                  ),
                  Divider(),
                  RaisedButton(
                    onPressed: () => onExportPressed(),
                    color: Theme.of(context).accentColor,
                    child: Text(
                      globals.exportScreenToShowDeleteDB
                      ? "Exportálás, adatbázis törlése, majd app bezárása"
                      : I18n.of(context).export,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ]),
          ),
        ),
        "/settings",
        <Widget>[]);
  }

//todo be lehetne illeszteni a BUILD törzsébe ;D
  Widget dinamicWidget(int id) {
    if (id == 2) return Divider(); //ha kiválasztott: fiókok
    return Column(
      children: <Widget>[
        DropdownButton(
          items: globals.users.map((User user) {
            return DropdownMenuItem(
              child: Text(user.name),
              value: user,
            );
          }).toList(),
          onChanged: (user) async {
            selectedUser = user;
            updateURL();
          },
          value: selectedUser,
        ),
        (id == 1) //ha kiválasztott: órák
            ? MaterialButton(
          color: selectedDate == null
              ? Colors.deepOrangeAccent
              : Colors.green,
          onPressed: () async {
            final List<DateTime>
            picked = await DateRagePicker.showDatePicker(
                context: context,
                initialFirstDate: DateTime.now()
                    .subtract(
                    Duration(days: DateTime
                        .now()
                        .weekday - 1)),
                initialLastDate: DateTime.now().subtract(
                    Duration(days: DateTime
                        .now()
                        .weekday - 7)),
                firstDate: DateTime(2018),
                lastDate: DateTime(2025));
            if (picked != null && picked.length == 2) {
              pickedDate = picked;
              selectedDate =
                  picked[0].toIso8601String().substring(0, 10) +
                      "  -  " +
                      picked[1].toIso8601String().substring(0, 10);
              updateURL();
            }
          },
          child: Text(selectedDate ?? I18n
              .of(context)
              .exportChoose),
        )
            : Container(),
        DropdownButton(
          items: formats.map((String format) {
            return DropdownMenuItem(
              child: Text(format.toUpperCase().substring(1, format.length)),
              value: format,
            );
          }).toList(),
          onChanged: (format) async {
            selectedFormat = formats.indexOf(format);
            updateURL();
          },
          value: formats[selectedFormat],
        )
      ],
    );
  }

  Future<void> onExportPressed() async {
    String data;
    if (selectedFormat == 0) {
      //json
      switch (selectedData) {
        case 0: //Jegyek
          Account selectedAccount = globals.accounts
              .firstWhere((Account a) => a.user.id == selectedUser.id);
          data = selectedAccount.getStudentString();
          break;
        case 1: //Órák
          data = await getLessonsJson(
              pickedDate[0], pickedDate[1], selectedUser, true);
          break;
        case 2: //Fiókok
          data = json.encode(await Saver.readUsers());
          break;
      }
    } else {
      //csv
      switch (selectedData) {
        case 0:
        //region Jegyek
          Account selectedAccount = globals.accounts
              .firstWhere((Account a) => a.user.id == selectedUser.id);
          Map _data = selectedAccount.getStudentJson();
          List<List<dynamic>> csvList = [
            [
              "EvaluationId",
              "Form",
              "FormName",
              "Type",
              "TypeName",
              "Subject",
              "SubjectCategory",
              "SubjectCategoryName",
              "Theme",
              "Mode",
              "Weight",
              "Value",
              "NumberValue",
              "SeenByTutelaryUTC",
              "Teacher",
              "Date",
              "CreatingTime"
            ]
          ];
          for (var jegy in _data["Evaluations"])
            csvList.add([
              jegy["EvaluationId"],
              jegy["Form"],
              jegy["FormName"],
              jegy["Type"],
              jegy["TypeName"],
              jegy["Subject"],
              jegy["SubjectCategory"],
              jegy["SubjectCategoryName"],
              jegy["Theme"],
              jegy["Mode"],
              jegy["Weight"],
              jegy["Value"],
              jegy["NumberValue"],
              jegy["SeenByTutelaryUTC"],
              jegy["Teacher"],
              jegy["Date"],
              jegy["CreatingTime"]
            ]);
          data = const ListToCsvConverter().convert(csvList);
          //endregion
          break;
        case 1:
        //region Órák
          var _data = json.decode(await getLessonsJson(
              pickedDate[0], pickedDate[1], selectedUser, true));
          List<List<dynamic>> csvList = [
            [
              "LessonId",
              "CalendarOraType",
              "Count",
              "Date",
              "StartTime",
              "EndTime",
              "Subject",
              "SubjectCategory",
              "SubjectCategoryName",
              "ClassRoom",
              "ClassGroup",
              "Teacher",
              "DeputyTeacher",
              "State",
              "StateName",
              "PresenceType",
              "PresenceTypeName",
              "TeacherHomeworkId",
              "IsTanuloHaziFeladatEnabled",
              "Theme",
              "Homework"
            ]
          ];
          for (var ora in _data)
            csvList.add([
              ora["LessonId"],
              ora["CalendarOraType"],
              ora["Count"],
              ora["Date"],
              ora["StartTime"],
              ora["EndTime"],
              ora["Subject"],
              ora["SubjectCategory"],
              ora["SubjectCategoryName"],
              ora["ClassRoom"],
              ora["ClassGroup"],
              ora["Teacher"],
              ora["DeputyTeacher"],
              ora["State"],
              ora["StateName"],
              ora["PresenceType"],
              ora["PresenceTypeName"],
              ora["TeacherHomeworkId"],
              ora["IsTanuloHaziFeladatEnabled"],
              ora["Theme"],
              ora["Homework"]
            ]);
          data = const ListToCsvConverter().convert(csvList);
          //endregion
          break;
      }
    }
    writeToFile(fullPath, data);

    if (globals.exportScreenToShowDeleteDB) {//If coming from db help popup
      DBHelper().clearDB();
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  bool writeToFile(String path, String data) {
    File file = File(path);
    try {
      //todo ismert hiba android 10 mec 5 security patch nem működik az export
      PermissionHandler().requestPermissions([PermissionGroup.storage]).then(
              (Map<PermissionGroup, PermissionStatus> permissions) {
            file.writeAsString(data).then((File f) {
              if (f.existsSync())
                Fluttertoast.showToast(
                    msg: I18n
                        .of(context)
                        .exportSuccess + ": " + path,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
              return true;
            });
            return false;
          });
    } catch (_) {
      Fluttertoast.showToast(
          msg: "Fájl műveleti hiba", //todo fordítás
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
    return false;
  }
}
