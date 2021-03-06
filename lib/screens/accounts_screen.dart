import 'dart:async';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import 'package:filcnaplo/models/account.dart';
import 'package:filcnaplo/models/user.dart';

import 'package:filcnaplo/utils/account_manager.dart';
import 'package:filcnaplo/utils/saver.dart';

import 'package:filcnaplo/globals.dart' as globals;

import 'package:filcnaplo/screens/student_screen.dart';
import 'package:filcnaplo/screens/login_screen.dart';
import 'package:filcnaplo/utils/string_formatter.dart';

import 'package:filcnaplo/screens/screen.dart';

void main() {
  runApp(MaterialApp(home: AccountsScreen()));
}

class AccountsScreen extends StatefulWidget {
  @override
  AccountsScreenState createState() => AccountsScreenState();
}

class AccountsScreenState extends State<AccountsScreen> {
  Color selected;

  void addPressed() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen(
                  fromApp: true,
                )),
      );
    });
  }

  List<User> users;
  Future<List<User>> _getUserList() async {
    return await AccountManager().getUsers();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      performInitState();
    });
  }

  void performInitState() async {
    users = await _getUserList();
    _getListWidgets();
  }

  void _openDialog(String title, Widget content, User user) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        contentPadding: const EdgeInsets.all(6.0),
        title: Text(title),
        content: content,
        actions: [
          FlatButton(
            child: Text(I18n.of(context).dialogNo.toUpperCase()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(I18n.of(context).dialogOk.toUpperCase()),
            onPressed: () async {
              Navigator.of(context).pop();
              users[users.map((User u) => u.id).toList().indexOf(user.id)]
                  .color = selected;
              await saveUsers(users);
              setState(() {
                globals.users = users;
                if (globals.selectedUser.id == user.id)
                  globals.selectedUser.color = selected;
                for (Account account in globals.accounts)
                  if (account.user.id == user.id) account.user.color = selected;
                _getListWidgets();
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _getListWidgets() async {
    if (users.isEmpty) Navigator.pushNamed(context, "/login");
    accountListWidgets = List();
    for (Account a in globals.accounts) {
      setState(() {
        accountListWidgets.add(
          ListTile(
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: IconButton(
                    onPressed: () {
                      _openDialog(
                          I18n.of(context).color,
                          MaterialColorPicker(
                            selectedColor: selected,
                            onColorChange: (Color c) => selected = c,
                          ),
                          a.user);
                    },
                    icon: Icon(
                      Icons.color_lens,
                      color: a.user.color,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    _removeUserDialog(a.user).then((nul) async {
                      users = await AccountManager().getUsers();
                      globals.accounts.removeWhere((Account a) =>
                          !users.map((User u) => u.id).contains(a.user.id));
                      await _getListWidgets();
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            title: Text(a.user.name),
            leading: GestureDetector(
              child: Icon(Icons.person_outline),
              onTap: () async {
                await a.refreshStudentString(true, false);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => StudentScreen(
                              account: a,
                            )));
              },
            ),
          ),
        );
        accountListWidgets.add(
          Divider(
            height: 1.0,
          ),
        );
      });
    }

    setState(() {
      accountListWidgets.add(IconButton(
          onPressed: addPressed,
          icon: Icon(
            Icons.add,
            color: globals.CurrentTextColor,
          )));
    });
  }

  Future<Null> _removeUserDialog(User user) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(capitalize(I18n.of(context).accountDelete)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(I18n.of(context).accountDeleteConfirm(user.name)),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(I18n.of(context).dialogNo.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(I18n.of(context).dialogYes.toUpperCase()),
              onPressed: () async {
                await AccountManager().removeUser(user);
                setState(() {
                  globals.accounts
                      .removeWhere((Account a) => a.user.id == user.id);
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, "/accounts");
                });
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> accountListWidgets;

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    return Screen(
        Text(capitalize(I18n.of(context).accountTitle)),
        Column(children: <Widget>[
          Expanded(
            child: Container(
                child: accountListWidgets != null
                    ? ListView(
                        children: accountListWidgets,
                      )
                    : CircularProgressIndicator()),
          ),
        ]),
        "/home",
        <Widget>[]);
  }
}
