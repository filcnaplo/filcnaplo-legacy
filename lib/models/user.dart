import 'package:flutter/material.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'dart:convert';

class User {
  int id;
  String username;
  String password;
  String name;
  String schoolCode;
  String schoolUrl;
  String schoolName;
  String parentName;
  String parentId;
  Color color;
  Map<String, String> lastRefreshMap = Map();
  static const RATE_LIMIT_MINUTES = 1;

  User(this.id, this.username, this.password, this.name, this.schoolCode,
      this.schoolUrl, this.schoolName, this.parentName, this.parentId);

  User.fromJson(Map userJson) {
    id = userJson["id"];
    username = userJson["username"];
    password = userJson["password"];
    name = userJson["name"];
    schoolCode = userJson["schoolCode"];
    schoolUrl = userJson["schoolUrl"];
    schoolName = userJson["schoolName"];
    parentName = userJson["parentName"];
    parentId = userJson["parentId"];
    try {
      color = Color(userJson["color"]);
    } catch (e) {
      color = Color(0);
    }
    try {
      // lastRefreshMap = userJson["lastRefreshMap"];
      print("[i] User.fromJson(): lastRefreshMap size = " +
          (userJson["lastRefreshMap"].length).toString());
    } catch (e) {
      print("[E] User.fromJson(): " + e.toString());
    }
  }

  bool isSelected() => id == globals.selectedUser.id;

  bool getRecentlyRefreshed(String request) {
    if (lastRefreshMap != null) {
      if (lastRefreshMap.containsKey(request)) {
        return DateTime.now()
                .difference(DateTime.parse(lastRefreshMap[request]))
                .inMinutes <
            RATE_LIMIT_MINUTES;
      }
    }
    return false;
  }

  void setRecentlyRefreshed(String request) {
    lastRefreshMap.update(
        request, (String s) => DateTime.now().toIso8601String(),
        ifAbsent: () => DateTime.now().toIso8601String());
  }

  Map<String, dynamic> toMap() {
    var userMap = {
      "id": id,
      "username": username,
      "password": password,
      "name": name,
      "schoolCode": schoolCode,
      "schoolUrl": schoolUrl,
      "schoolName": schoolName,
      "parentName": parentName,
      "parentId": parentId,
      "color": color != null ? color.value : 0,
      "lastRefreshMap": lastRefreshMap,
    };

    return userMap;
  }
}
