import 'dart:async';
import 'dart:convert' show json, utf8;
import 'package:filcnaplo/models/lesson.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo/utils/saver.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/generated/i18n.dart';
import "dart:math";

class RequestHelper {
  var randomDeviceCodeNames = [
    "coral",
    "flame",
    "clark",
    "walleye",
    "a6eltemtr",
    "gracelte",
    "klte",
    "kwifi",
    "zerofltectc",
    "heroqltecctvzw",
    "a50",
    "beyond1",
    "H8416",
    "SOV38",
    "a6lte",
    "OnePlus7",
    "flashlmdd",
    "hammerhead",
    "mako",
    "lucye",
    "bullhead",
    "griffin",
    "h1",
    "HWBKL",
    "HWMHA",
    "HWALP",
    "cheeseburger",
    "bonito",
    "crosshatch",
    "taimen",
    "blueline"
  ];
  final _random = Random();
  void showError(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void showSuccess(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<String> getInstitutes() async {
    String institutesBody =
        utf8.decode((await http.get(globals.INSTITUTES_API_URL)).bodyBytes);
    return institutesBody;
  }

  void refreshAppSettings() async {
    try {
      String settings =
          utf8.decode((await http.get(globals.SETTINGS_API_URL)).bodyBytes);
      Map settingsJson = json.decode(settings);
      globals.latestVersion = settingsJson["LatestVersion"];
      if (globals.smartUserAgent) {
        var randomCodeName = randomDeviceCodeNames[
            _random.nextInt(randomDeviceCodeNames.length)];
        globals.userAgent = settingsJson["KretaUserAgent"].split(" ")[0];
      } else {
        globals.userAgent = "FilcNaplo/" + globals.version;
      }
    } catch (e) {
      print("[E] RequestHelper.refreshAppSettings(): " + e.toString());
    }
  }

  Future<String> apiRequest(
      String url, String accessToken, String schoolCode) async {
    if (accessToken != null) {
      http.Response response = await http.get(url, headers: {
        "HOST": schoolCode + ".e-kreta.hu",
        "User-Agent": globals.userAgent,
        "Authorization": "Bearer " + accessToken
      });

      return response.body;
    }
  }

  Future<List> apiRequestRaw(
      String url, String accessToken, String schoolCode) async {
    if (accessToken != null) {
      http.Response response = await http.get(url, headers: {
        "HOST": schoolCode + ".e-kreta.hu",
        "User-Agent": globals.userAgent,
        "Authorization": "Bearer " + accessToken
      });

      return response.bodyBytes;
    }
  }

  Future<String> getTests(String accessToken, String schoolCode) => apiRequest(
      "https://" +
          schoolCode +
          ".e-kreta.hu/mapi/api/v1/BejelentettSzamonkeres?DatumTol=null&DatumIg=null",
      accessToken,
      schoolCode);
  Future<String> getMessages(String accessToken, String schoolCode) => apiRequest(
      "https://eugyintezes.e-kreta.hu/integration-kretamobile-api/v1/kommunikacio/postaladaelemek/sajat",
      accessToken,
      schoolCode);
  Future<String> getMessageById(
          int id, String accessToken, String schoolCode) =>
      apiRequest(
          "https://eugyintezes.e-kreta.hu/integration-kretamobile-api/v1/kommunikacio/postaladaelemek/$id",
          accessToken,
          schoolCode);

  Future downloadAttachment(int id, String accessToken, String schoolCode) =>
      apiRequestRaw(
          "https://eugyintezes.e-kreta.hu/integration-kretamobile-api/v1/dokumentumok/uzenetek/$id",
          accessToken,
          schoolCode);

  Future<String> getEvaluations(String accessToken, String schoolCode) =>
      apiRequest(
          "https://" + schoolCode + ".e-kreta.hu" + "/mapi/api/v1/StudentAmi",
          accessToken,
          schoolCode);
  Future<String> getHomework(String accessToken, String schoolCode, int id) =>
      apiRequest(
          "https://" +
              schoolCode +
              ".e-kreta.hu/mapi/api/v1/HaziFeladat/TanuloHaziFeladatLista/" +
              id.toString(),
          accessToken,
          schoolCode);
  Future<String> getHomeworkByTeacher(
          String accessToken, String schoolCode, int id) =>
      apiRequest(
          "https://" +
              schoolCode +
              ".e-kreta.hu/mapi/api/v1/HaziFeladat/TanarHaziFeladat/" +
              id.toString(),
          accessToken,
          schoolCode);
  Future<String> getEvents(String accessToken, String schoolCode) => apiRequest(
      "https://" + schoolCode + ".e-kreta.hu/mapi/api/v1/Event",
      accessToken,
      schoolCode);
  Future<String> getTimeTable(
          String from, String to, String accessToken, String schoolCode) =>
      apiRequest(
          "https://" +
              schoolCode +
              ".e-kreta.hu/mapi/api/v1/Lesson?fromDate=" +
              from +
              "&toDate=" +
              to,
          accessToken,
          schoolCode);
  Future<String> getBearer(
      String jsonBody, String schoolCode, bool showErrors) async {
    http.Response response;
    try {
      response = await http.post(
          "https://" + schoolCode + ".e-kreta.hu/idp/api/v1/Token",
          headers: {
            "HOST": schoolCode + ".e-kreta.hu",
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
            "User-Agent": globals.userAgent
          },
          body: jsonBody);
      return response.body;
    } catch (e) {
      if (showErrors) {
        print("[E] RequestHelper.getBearer(): " + e.toString());
        showError(e.toString());
      }
      return null;
    }
  }

  Future<bool> uploadHomework(String homework, Lesson lesson, User user) async {
    if (homework == null) {
      return false;
    }
    Map body = {
      "OraId": lesson.id.toString(),
      "OraDate": dateToHuman(lesson.date) + "00:00:00",
      "OraType": lesson.calendarOraType,
      "HataridoUtc":
          dateToHuman(lesson.date.add(Duration(days: 2))) + "23:00:00",
      "FeladatSzovege": homework.replaceAll("\n", "&lt;br/&gt;")
    };
    String token = await getBearerToken(user, true);
    String jsonBody = json.encode(body);
    try {
      http.Response response = await http.post(
          "https://" +
              user.schoolCode +
              ".e-kreta.hu/mapi/api/v1/HaziFeladat/CreateTanuloHaziFeladat",
          headers: {
            "HOST": user.schoolCode + ".e-kreta.hu",
            "Authorization": "Bearer " + token,
            "Content-Type": "application/json; charset=utf-8",
            "User-Agent": globals.userAgent
          },
          body: jsonBody);
      if (response.statusCode == 200) {
        showSuccess(I18n.of(globals.context).successHomework);
        return true;
      } else {
        showError(I18n.of(globals.context).errorNetwork);
        print(response.statusCode.toString() + " " + response.body);
        return false;
      }
    } catch (e) {
      print("[E] RequestHelper.uploadHomework(): " + e.toString());
      showError(e.toString());
      return false;
    }
  }

  Future<bool> deleteHomework(int id, User user) async {
    if (id == null) {
      return false;
    }

    String token = await getBearerToken(user, true);
    try {
      http.Response response = await http.delete(
          "https://" +
              user.schoolCode +
              ".e-kreta.hu/mapi/api/v1/HaziFeladat/DeleteTanuloHaziFeladat/" +
              id.toString(),
          headers: {
            "HOST": user.schoolCode + ".e-kreta.hu",
            "Authorization": "Bearer " + token,
            "Accept": "application/json",
            "Content-Type": "application/json; charset=utf-8",
            "User-Agent": globals.userAgent
          });
      if (response.statusCode == 200) {
        showSuccess(I18n.of(globals.context).successHomeworkDelete);
        return true;
      } else {
        showError(I18n.of(globals.context).errorNetwork);
        print(response.statusCode.toString() + " " + response.body);
        return false;
      }
    } catch (e) {
      print("[E] RequestHelper.deleteHomework(): " + e.toString());
      showError(e.toString());
      return false;
    }
  }

  Future<String> getBearerToken(User user, bool showErrors) async {
    String body = "institute_code=${user.schoolCode}&"
            "userName=${user.username}&"
            "password=${user.password}&"
            "grant_type=password&client_id=" +
        globals.clientId;
    String bearerResponse =
        await RequestHelper().getBearer(body, user.schoolCode, showErrors);
    if (bearerResponse != null) {
      try {
        Map<String, dynamic> bearerMap = json.decode(bearerResponse);
        if (bearerMap["error"] == "invalid_grant" && showErrors)
          showError("Hibás jelszó vagy felhasználónév");
        String code = bearerMap["access_token"];
        return code;
      } catch (e) {
        print("[E] RequestHelper.getBearerToken(): " + e.toString());
        //showError(e.toString());
        return null;
      }
    }
    return null;
  }

  void seeMessage(int id, User user) async {
    try {
      String code = await getBearerToken(user, true);
      await http.post(
          "https://eugyintezes.e-kreta.hu//integration-kretamobile-api/v1/kommunikacio/uzenetek/olvasott",
          headers: {
            "Authorization": ("Bearer " + code),
          },
          body: "{\"isOlvasott\":true,\"uzenetAzonositoLista\":[$id]}");
    } catch (e) {
      print("[E] RequestHelper.seeMessage(): " + e.toString());
      showError(e.toString());
      return null;
    }
  }

  Future<String> getStudentString(User user, bool showErrors) async {
    String code = await getBearerToken(user, showErrors);
    String evaluationsString = await getEvaluations(code, user.schoolCode);
    return evaluationsString;
  }

  Future<String> getEventsString(User user, bool showErrors) async {
    String code = await getBearerToken(user, showErrors);
    String eventsString = await getEvents(code, user.schoolCode);
    saveEvents(eventsString, user);
    return eventsString;
  }
}
