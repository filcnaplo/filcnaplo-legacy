import 'dart:async';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import 'package:filcnaplo/Datas/Account.dart';
import 'package:filcnaplo/Datas/User.dart';

import 'package:filcnaplo/GlobalDrawer.dart';

import 'package:filcnaplo/Utils/AccountManager.dart';
import 'package:filcnaplo/Utils/Saver.dart';

import 'package:filcnaplo/globals.dart' as globals;

import 'package:filcnaplo/screens/studentScreen.dart';
import 'package:filcnaplo/screens/loginScreen.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';

void main() {
  runApp(new MaterialApp(home: new AccountsScreen()));
}

class AccountsScreen extends StatefulWidget {
  @override
  AccountsScreenState createState() => new AccountsScreenState();
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
                  child: FlatButton(
                    onPressed: () {
                      _openDialog(
                          I18n.of(context).color,
                          MaterialColorPicker(
                            selectedColor: selected,
                            onColorChange: (Color c) => selected = c,
                          ),
                          a.user);
                    },
                    child: Icon(
                      Icons.color_lens,
                      color: a.user.color,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () async {
                    _removeUserDialog(a.user).then((nul) async {
                      users = await AccountManager().getUsers();
                      globals.accounts.removeWhere((Account a) =>
                          !users.map((User u) => u.id).contains(a.user.id));
                      await _getListWidgets();
                      setState(
                          () {}); //TODO Ez így lehet hogy full felesleges, delete this line if so
                    });
                  },
                  child: Icon(
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
      accountListWidgets.add(FlatButton(
          onPressed: addPressed,
          child: Icon(
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
    return WillPopScope(
      onWillPop: () {
        globals.screen = 0;
        Navigator.pushReplacementNamed(context, "/main");
      },
      child: Scaffold(
        drawer: GDrawer(),
        appBar: AppBar(
          title: Text(capitalize(I18n.of(context).accountTitle)),
          actions: <Widget>[],
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: Container(
                child: accountListWidgets != null
                    ? ListView(
                        children: accountListWidgets,
                      )
                    : CircularProgressIndicator()),
          ),
        ]),
      ),
    );
  }
}
