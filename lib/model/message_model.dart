class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;
  String? msgType;

  MessageModel({
    this.sender,
    this.text,
    this.seen,
    this.createdOn,
    this.messageId,
    this.msgType,
  });

  MessageModel.fomMap(Map<String, dynamic> map) {
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    messageId = map["messageId"];
    createdOn = map["createdOn"].toDate();
    msgType = map["msgType"];
  }

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdOn": createdOn,
      "messageId": messageId,
      "msgType": msgType,
    };
  }
}
