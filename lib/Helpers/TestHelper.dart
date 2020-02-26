import 'dart:async';
import 'package:filcnaplo/Datas/Test.dart';
import 'package:filcnaplo/Datas/User.dart';

class TestHelper {
  List<dynamic> testsMap;

  Future<List<Test>> getTestsFrom(List testsJson, User user) async {
    List<Test> testsList = List();
    try {
      for (dynamic d in testsJson) {
        testsList.add(Test.fromJson(d));
      }

      testsList.forEach((Test test) => test.owner = user);
    } catch (e) {
      print("[E] TestHelper.getTestsFrom():" + e.toString());
    }

    return testsList;
  }
}
