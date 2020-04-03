class Attachment {
  int id;
  String fileName;

  Attachment.fromJson(Map json) {
    this.id = json["azonosito"];
    this.fileName = json["fileName"];
  }
}
