// ignore_for_file: prefer_initializing_formals

class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  String? lastMessageTime;
  String? user1;
  String? user2;

  ChatRoomModel({
    this.chatRoomId,
    this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.user1,
    this.user2,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map["chatRoomId"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    lastMessageTime = map["lastMessageTime"];
    user1 = map["user1"];
    user2 = map["user2"];
  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "participants": participants,
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime,
      "user1": user1,
      "user2": user2,
    };
  }
}
