import 'dart:convert' show json;
import 'dart:io';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:filcnaplo/models/account.dart';
import 'package:filcnaplo/models/institution.dart';
import 'package:filcnaplo/models/user.dart';

import 'package:filcnaplo/helpers/request_helper.dart';
import 'package:filcnaplo/helpers/user_info_helper.dart';

import 'package:filcnaplo/utils/account_manager.dart';

import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/utils/string_formatter.dart';

LoginScreenState loginScreenState = LoginScreenState();

class LoginScreen extends StatefulWidget {
  LoginScreen({this.fromApp});

  bool fromApp = false;

  @override
  LoginScreenState createState() => LoginScreenState();
}

Icon helpIconSwitch = Icon(
  IconData(0xf625, fontFamily: "Material Design Icons"),
  color: Colors.white12,
);
bool helpSwitch = false;

void helpToggle() {
  helpSwitch = !helpSwitch;
  if (helpSwitch) {
    helpIconSwitch = Icon(
      IconData(0xf625, fontFamily: "Material Design Icons"),
      color: Colors.white,
    );
  } else {
    helpIconSwitch = Icon(
      IconData(0xf625, fontFamily: "Material Design Icons"),
      color: Colors.white12,
    );
  }
}

void showToggle() {
  showSwitch = !showSwitch;
  if (showSwitch) {
    showIconSwitch = Icon(
      Icons.remove_red_eye,
      color: Colors.white,
    );
  } else {
    showIconSwitch = Icon(
      Icons.remove_red_eye,
      color: Colors.white12,
    );
  }
}

Icon showIconSwitch = Icon(
  Icons.remove_red_eye,
  color: Colors.white12,
);
bool showSwitch = false;

String userName = "";
String password = "";

String userError;
String passwordError;
bool schoolSelected = true;

double kbSize;

bool isDialog = false;

bool loggingIn = false;

final userNameController = TextEditingController();
final passwordController = TextEditingController();

class LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    loggingIn = false;
    super.initState();
  }

  void initJson() async {
    String data = await RequestHelper().getInstitutes();
    try {
      globals.jsonres = json.decode(data);
    } catch (e) {
      print("[E] loginScreen.initJson(): " + e.toString());
      Fluttertoast.showToast(
        msg: "Nem sikerült lekérni a Krétás iskolákat.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      globals.jsonres = json.decode(data);
    }

    globals.jsonres.sort((dynamic a, dynamic b) {
      return a["Name"].toString().compareTo(b["Name"].toString());
    });

    globals.searchres = json.decode(data);

    globals.searchres.sort((dynamic a, dynamic b) {
      return a["Name"].toString().compareTo(b["Name"].toString());
    });

    if (isDialog) {
      myDialogState.setState(() {});
    }
  }

  void login(BuildContext context) async {
    userError = null;
    passwordError = null;

    try {
      final result = await InternetAddress.lookup('e-kreta.hu');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        password = passwordController.text;
        userName = userNameController.text;
        userError = null;
        passwordError = null;
        schoolSelected = true;
        String bearerResp;
        String code;
        if (userName == "") {
          userError = I18n.of(context).loginUsernameError;
          setState(() {
            loggingIn = false;
          });
        } else if (password == "") {
          setState(() {
            loggingIn = false;
          });
          passwordError = I18n.of(context).loginPasswordError;
        } else if (globals.selectedSchoolUrl == "") {
          setState(() {
            loggingIn = false;
          });
          schoolSelected = false;
        } else {
          String instCode = globals.selectedSchoolCode; //suli kódja
          String jsonBody = "institute_code=" +
              instCode +
              "&userName=" +
              userName +
              "&password=" +
              password +
              "&grant_type=password&client_id=" +
              globals.clientId;

          try {
            bearerResp =
                await RequestHelper().getBearer(jsonBody, instCode, false);
            Map<String, dynamic> bearerMap = json.decode(bearerResp);
            code = bearerMap.values.toList()[0];

            Map<String, String> userInfo = await UserInfoHelper()
                .getInfo(instCode, userName, password, false);

            setState(() {
              User user = User(
                  int.parse(userInfo["StudentId"]),
                  userName,
                  password,
                  userInfo["StudentName"],
                  instCode,
                  globals.selectedSchoolUrl,
                  globals.selectedSchoolName,
                  userInfo["ParentName"],
                  userInfo["ParentId"]);
              AccountManager().addUser(user);

              globals.users.add(user);

              globals.multiAccount = globals.users.length != 1;

              globals.accounts = List();
              for (User user in globals.users)
                globals.accounts.add(Account(user));
              globals.selectedAccount = globals.accounts
                  .firstWhere((Account account) => account.user.id == user.id);
              globals.selectedUser = user;

              Navigator.pushNamed(context, "/home");
            });
          } catch (e) {
            setState(() {
              loggingIn = false;
            });
            print("[E] loginScreen.login(): " + e.toString());
            setState(() {
              if (code == "invalid_grant") {
                passwordError = "hibás felasználónév vagy jelszó";
              } else if (code == "invalid_password") {
                passwordError = "hibás felasználónév vagy jelszó";
              } else {
                passwordError = "ismeretlen probléma: " +
                    code.toString();
              }
            });
          }
        }
      } else {
        setState(() {
          loggingIn = false;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        loggingIn = false;
      });
      passwordError = "nincs internet";
    }
  }

  void showSelectDialog() {
    initJson();
    setState(() {
      myDialogState = MyDialogState();
      showDialog<Institution>(
          context: context,
          builder: (BuildContext context) {
            return MyDialog();
          }).then((dynamic) {
        setState(() {});
      });
    });
  }

  _gotoAbout() {
    Navigator.popAndPushNamed(context, "/about");
  }

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    return WillPopScope(
        onWillPop: () {
          if (widget.fromApp)
            Navigator.pushReplacementNamed(context, "/accounts");
        },
        child: Scaffold(
            body: Container(
                color: Colors.black87,
                child: Center(
                    child: !loggingIn
                        ? Container(
                            child: ListView(
                            reverse: true,
                            padding:
                                EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    left: 40.0, right: 40.0),
                                child: Image.asset("assets/icon.png"),
                                height: kbSize,
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 5.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Flexible(
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.white),
                                            controller: userNameController,
                                            decoration: InputDecoration(
                                              prefixIcon:
                                                  Icon(Icons.person),
                                              suffixIcon: IconButton(
                                                  icon: helpIconSwitch,
                                                  onPressed: () {
                                                    setState(() {
                                                      helpToggle();
                                                    });
                                                  }),
                                              hintText: I18n.of(context)
                                                  .loginUsername,
                                              hintStyle: TextStyle(
                                                  color: Colors.white30),
                                              errorText: userError,
                                              fillColor: Color.fromARGB(
                                                  40, 20, 20, 30),
                                              filled: true,
                                              helperText: helpSwitch
                                                  ? I18n.of(context)
                                                      .loginUsernameHint
                                                  : null,
                                              helperStyle: TextStyle(
                                                  color: Colors.white30),
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      5.0, 15.0, 5.0, 15.0),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  gapPadding: 1.0,
                                                  borderSide: BorderSide(
                                                    color: Colors.green,
                                                    width: 2.0,
                                                  )),
                                            ),
                                          ),
                                        ),
                                      ])),
                              Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.white),
                                        controller: passwordController,
                                        keyboardType: TextInputType.text,
                                        obscureText: !showSwitch,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.https),
                                          suffixIcon: IconButton(
                                              icon: showIconSwitch,
                                              onPressed: () {
                                                setState(() {
                                                  showToggle();
                                                });
                                              }),
                                          hintStyle:
                                              TextStyle(color: Colors.white30),
                                          hintText:
                                              I18n.of(context).loginPassword,
                                          errorText: passwordError,
                                          fillColor:
                                              Color.fromARGB(40, 20, 20, 30),
                                          filled: true,
                                          helperText: helpSwitch
                                              ? I18n.of(context)
                                                  .loginPasswordHint
                                              : null,
                                          helperStyle:
                                              TextStyle(color: Colors.white30),
                                          contentPadding: EdgeInsets.fromLTRB(
                                              5.0, 15.0, 5.0, 15.0),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              gapPadding: 1.0,
                                              borderSide: BorderSide(
                                                color: Colors.deepOrange,
                                                width: 2.0,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ])),
                              Column(children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0.0, 10.0, 0.0, 5.0),
                                  padding: EdgeInsets.fromLTRB(
                                      10.0, 4.0, 10.0, 4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Color.fromARGB(40, 20, 20, 30),
                                    border: Border.all(
                                      color: schoolSelected
                                          ? Colors.black87
                                          : Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        I18n.of(context).loginSchool + ": ",
                                        style: TextStyle(
                                            fontSize: 21.0,
                                            color: Colors.white30),
                                      ),
                                      Expanded(
                                        child: FlatButton(
                                          onPressed: () {
                                            showSelectDialog();
                                            setState(() {});
                                          },
                                          child: Text(
                                            globals.selectedSchoolName ??
                                                I18n.of(context).loginChoose,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                !schoolSelected
                                    ? Text(
                                        I18n.of(context).loginSchoolError,
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : Container(),
                              ]),
                              Row(
                                children: <Widget>[
                                  !Platform.isIOS
                                      ? Expanded(
                                          child: Container(
                                          child: FlatButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, "/import");
                                            },
                                            child: Text("Import"),
                                            disabledColor: Colors.blueGrey[800],
                                            disabledTextColor: Colors.blueGrey,
                                            color: Colors.green,
                                            //#2196F3
                                            textColor: Colors.white,
                                          ),
                                        ))
                                      : Container(),
                                ],
                              ),
                              FlatButton(
                                onPressed: !loggingIn
                                    ? () {
                                        setState(() {
                                          loggingIn = true;
                                          login(context);
                                        });
                                      }
                                    : null,
                                disabledColor: Colors.blueGrey.shade800,
                                disabledTextColor: Colors.blueGrey,
                                child: Text(
                                    capitalize(I18n.of(context).login)),
                                color: Colors.blue,
                                //#2196F3
                                textColor: Colors.white,
                              ),
                            ].reversed.toList(),
                          ))
                        : Container(
                            child: CircularProgressIndicator(),
                          )))));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog();
  @override
  State createState() {
    if (globals.jsonres != null) globals.searchres.addAll(globals.jsonres);
    return myDialogState;
  }
}

MyDialogState myDialogState = MyDialogState();

class MyDialogState extends State<MyDialog> {
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    isDialog = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isDialog = true;
  }

  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(I18n.of(context).loginChooseSchool + ":"),
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        Container(
          child: TextField(
              maxLines: 1,
              autofocus: true,
              onChanged: (String search) {
                setState(() {
                  updateSearch(search);
                });
              }),
          margin: EdgeInsets.all(10.0),
        ),
        Container(
          child: globals.searchres != null
              ? ListView.builder(
                  itemBuilder: _itemBuilder,
                  itemCount: globals.searchres.length,
                )
              : Container(),
          width: 320.0,
          height: 400.0,
        )
      ],
    );
  }

  void updateSearch(String searchText) {
    setState(() {
      globals.searchres.clear();
      globals.searchres.addAll(globals.jsonres);
    });
    if (searchText != "") {
      setState(() {
        globals.searchres.removeWhere((dynamic element) => !element
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase()));
      });
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(globals.searchres[index]["Name"]),
          subtitle: Text(globals.searchres[index]["Url"]),
          onTap: () {
            setState(() {
              globals.selectedSchoolCode =
                  globals.searchres[index]["InstituteCode"];
              globals.selectedSchoolUrl = globals.searchres[index]["Url"];
              globals.selectedSchoolName = globals.searchres[index]["Name"];
              Navigator.pop(context);
            });
          },
        ),
        Container(
          child: Text(globals.searchres[index]["City"]),
          alignment: Alignment(1.0, 0.0),
        )
      ],
    );
  }
}
