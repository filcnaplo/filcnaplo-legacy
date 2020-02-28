import 'User.dart';

class Homework {
  int id;
  String classGroup;
  String subject;
  String uploader;
  bool byTeacher;
  int lessonId;
  int lessonCount; //oraszam
  String text;
  String uploadDate;
  String deadline;
  String isStudentHomeworkEnabled;
  User owner;
  int deletedBy;

  Homework(
      this.id,
      this.classGroup,
      this.subject,
      this.uploader,
      this.byTeacher,
      this.lessonCount,
      this.text,
      this.uploadDate,
      this.deadline,
      this.isStudentHomeworkEnabled,
      this.owner,
      this.deletedBy);

  Homework.fromJson(Map json) {
    id = json["Id"];
    classGroup = json["OsztalyCsoport"];
    subject = json["Tantargy"];
    if (subject == null) subject = json["subject"];
    uploader = json["Rogzito"];
    if (uploader == null) uploader = json["TanuloNev"];
    if (json["isTanarRogzitette"] == null) {
      byTeacher = false;
    } else {
      byTeacher = json["IsTanarRogzitette"];
    }
    lessonCount = json["Oraszam"];
    lessonId = json["TanitasiOraId"];
    text = json["Szoveg"];
    if (text == null) text = json["FeladatSzovege"];
    uploadDate = json["FeladasDatuma"];
    deadline = json["Hatarido"];
    //isStudentHomeworkEnabled = json["IsTanuloHaziFeladatEnabled"] as String;
    owner = json["user"];
    if (json["TanuloAltalTorolt"] == true) {
      deletedBy = 1;
    } else if (json["TanarAltalTorolt"] == true) {
      deletedBy = 2;
    } else {
      deletedBy = 0;
    }
  }
}
