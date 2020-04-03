import 'package:filcnaplo/models/attachment.dart';

class Message {
  int id;
  int messageId;
  bool seen;
  DateTime date;
  String senderName;
  String senderType;
  String text;
  String subject;
  List<String> receivers;
  List<Attachment> attachments;

  Message.fromJson(Map json) {
    this.id = json["azonosito"];
    this.messageId = json["uzenet"]["azonosito"];
    this.seen = json["isElolvasva"];
    this.date = DateTime.parse(json["uzenet"]["kuldesDatum"]);
    this.senderName = json["uzenet"]["feladoNev"];
    this.senderType = json["uzenet"]["feladoTitulus"];
    this.text = json["uzenet"]["szoveg"];
    this.subject = json["uzenet"]["targy"];
    this.receivers = List();
    for (var rec in json["uzenet"]["cimzettLista"]) {
      this.receivers.add(rec["nev"]);
    }
    this.attachments = List();
    for (var att in json["uzenet"]["csatolmanyok"]) {
      this.attachments.add(Attachment.fromJson(att));
    }
  }
}
