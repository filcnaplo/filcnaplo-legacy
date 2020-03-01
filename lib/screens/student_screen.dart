import 'dart:ui';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';

import 'package:filcnaplo/models/account.dart';
import 'package:filcnaplo/models/student.dart';
import 'package:filcnaplo/global_drawer.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/globals.dart' as globals;

class StudentScreen extends StatefulWidget {
  StudentScreen({this.account});
  Account account;
  @override
  StudentScreenState createState() => StudentScreenState();
}

class StudentScreenState extends State<StudentScreen> {
  @override
  Widget build(BuildContext context) {
    globals.context = context;
    double c_width = MediaQuery.of(context).size.width * 0.5;

    return Scaffold(
      drawer: GDrawer(),
      appBar: AppBar(
        title: Text(this.widget.account.student != null
            ? this.widget.account.student.Name ?? ""
            : ""),
        actions: <Widget>[],
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Card(
              child: ListTile(
                title: Text(I18n.of(context).infoBirthdate),
                trailing: this.widget.account.student != null
                    ? Text(dateToHuman(DateTime.parse(
                            this.widget.account.student.DateOfBirthUtc ?? "")
                        .add(Duration(days: 1))))
                    : Container(),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(I18n.of(context).infoKretaID),
                trailing: Text(this.widget.account.student.StudentId != null
                    ? this.widget.account.student.StudentId.toString()
                    : "-"),
              ),
            ),
            Card(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Text(I18n.of(context).infoAddress),
                      padding: EdgeInsets.all(18),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: widget.account.student.AddressDataList
                          .toSet()
                          .toList()
                          .map((String address) {
                        return Text(
                          address,
                          maxLines: 3,
                          softWrap: true,
                          textAlign: TextAlign.end,
                        );
                      }).toList(),
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                    width: c_width,
                    margin: EdgeInsets.only(right: 15, left: 15),
                  ),
                ],
              ),
            ),
            widget.account.student.FormTeacher != null
                ? Card(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Text(
                              I18n.of(context).infoTeacher,
                              softWrap: false,
                              maxLines: 1,
                            ),
                            padding: EdgeInsets.all(18),
                          ),
                        ),
                        Container(
                          child: Column(
                            children: <String>[
                              widget.account.student.FormTeacher.Name ?? "",
                              widget.account.student.FormTeacher.Email ?? "",
                              widget.account.student.FormTeacher.PhoneNumber ??
                                  ""
                            ]
                                .where((String data) => data != "")
                                .map((String data) {
                              return Text(
                                data,
                                maxLines: 3,
                                softWrap: true,
                                textAlign: TextAlign.end,
                              );
                            }).toList(),
                            crossAxisAlignment: CrossAxisAlignment.end,
                          ),
                          width: c_width,
                          margin: EdgeInsets.only(right: 15, left: 15),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Card(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Text(I18n.of(context).infoSchool),
                      padding: EdgeInsets.all(18),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: <String>[
                        widget.account.student.InstituteName ?? "",
                        widget.account.student.InstituteCode ?? ""
                      ].map((String data) {
                        return Text(
                          data,
                          maxLines: 3,
                          softWrap: true,
                          textAlign: TextAlign.end,
                        );
                      }).toList(),
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                    width: c_width,
                    margin: EdgeInsets.only(right: 15, left: 15),
                  ),
                ],
              ),
            ),
            widget.account.student.Tutelaries != null
                ? Card(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Text(I18n.of(context).infoParents),
                            padding: EdgeInsets.all(18),
                          ),
                        ),
                        Container(
                          child: Column(
                            children: widget.account.student.Tutelaries
                                .map((TutelariesBean parrent) {
                              String details = (parrent.PhoneNumber != null &&
                                      parrent.PhoneNumber != "" &&
                                      parrent.Email != null &&
                                      parrent.Email != "")
                                  ? ":\n- " +
                                      parrent.PhoneNumber +
                                      "\n- " +
                                      parrent.Email
                                  : parrent.PhoneNumber != null &&
                                          parrent.PhoneNumber != ""
                                      ? ":\n- " + parrent.PhoneNumber.toString()
                                      : parrent.Email != null &&
                                              parrent.Email != ""
                                          ? ":\n- " + parrent.Email.toString()
                                          : "";
                              return Text(
                                parrent.Name + details,
                                maxLines: 3,
                                softWrap: true,
                                textAlign: TextAlign.start,
                              );
                            }).toList(),
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          width: c_width,
                          margin: EdgeInsets.only(right: 15, left: 15),
                        ),
                      ],
                    ),
                  )
                : Container(),
            widget.account.student.MothersName != null
                ? Card(
                    child: ListTile(
                      title: Text(I18n.of(context).infoMother),
                      trailing: Text(widget.account.student.MothersName),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
