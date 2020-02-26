import 'dart:async';
import 'dart:core';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:filcnaplo/Utils/Saver.dart';
import 'package:filcnaplo/Datas/User.dart';
import 'package:filcnaplo/Helpers/SettingsHelper.dart';

class AccountManager {
  Future<List<User>> getUsers() async {
    List<Map<String, dynamic>> usersJson = new List();
    try {
      usersJson = await readUsers();
    } catch (e) {
      print("[E] AccountManager.getUsers(): " + e.toString());
    }
    List<User> users = new List();
    if (usersJson.isNotEmpty)
      for (Map<String, dynamic> m in usersJson)
        users.add(User.fromJson(m));
    List<Color> colors = [Colors.green, Colors.red, Colors.black, Colors.brown, Colors.orange, Colors.blue];
    Iterator<Color> cit = colors.iterator;
    for (User u in users) {
      cit.moveNext();
      if (u.color.value == 0)
        u.color = cit.current;
    }
    return users;
  }

  void addUser(User user) async{
    try {
      List<User> users = await getUsers(); //Logging in with another account
      for (User u in users)
        if (u.id == user.id)
          return;
      users.add(user);
      globals.users = users;
      saveUsers(users);

      globals.isSingle = false;
      SettingsHelper().setSingleUser(false);

    } catch (e) { //Logging in with the first account
      List<User> users = new List();
      users.add(user);
      globals.users = users;
      saveUsers(users);

      globals.isSingle = true;
      SettingsHelper().setSingleUser(true);
    }
  }

  Future<void> removeUser(User user) async{
    List<User> users = await getUsers();
    List<User> newUsers = new List();
    for (User u in users)
      if (u.id!=user.id)
        newUsers.add(u);
    if (newUsers.length < 2) {
      globals.multiAccount = false;
      globals.isSingle = true;
      SettingsHelper().setSingleUser(true); //If only one user left, set SingleUser.
    }
    globals.users = newUsers;
    saveUsers(newUsers);
  }

  void removeUserIndex(int index) async{
    List<User> users = await getUsers();
    users.removeAt(index);
    saveUsers(users);
  }
}