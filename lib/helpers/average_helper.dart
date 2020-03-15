import 'dart:async';
import 'dart:convert' show json;
import 'package:filcnaplo/models/average.dart';
import 'package:filcnaplo/models/user.dart';

class AverageHelper {
  Future<List<Average>> getAveragesFrom(String studentString, User user) async {
    List<Average> averageList = List<Average>();

    Map<String, dynamic> studentMap = json.decode(studentString);

    List<Map<String, dynamic>> jsonAverageList = List<Map<String, dynamic>>();
    for (dynamic jsonAverage in studentMap["SubjectAverages"])
      jsonAverageList.add(jsonAverage as Map<String, dynamic>);

    jsonAverageList.forEach((Map<String, dynamic> jsonAverage) {
      averageList.add(Average.fromJson(jsonAverage));
    });

    return averageList;
  }
}
