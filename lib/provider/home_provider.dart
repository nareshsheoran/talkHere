
import 'dart:async';
import 'dart:io';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_service/firebase_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app/data_All/SharedPreferences.dart';
import 'package:whats_app/data_All/app_color.dart';
import 'package:whats_app/data_All/font_sizes.dart';
import 'package:whats_app/model/chat_room_model.dart';
import 'package:whats_app/model/message_model.dart';
import 'package:whats_app/model/user_model.dart';
import 'package:whats_app/notification_service.dart';
import 'package:whats_app/uiHelper/uiHelper.dart';
import 'package:whats_app/ui_design/chat_room.dart';
import 'package:whats_app/main.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:video_player/video_player.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirestoreService firestoreService = FirestoreService.instance;
  TextEditingController searchController = TextEditingController();
  TextEditingController massgController = TextEditingController();
  late VideoPlayerController videoController;
  List<MessageModel> userAllList = [];

  List<MessageModel> fMessage = [];
  File? sendFile;

  List<MessageModel> get message => fMessage;
  bool isLoading = false;

  onSearch() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('userPhone', isEqualTo: searchController.text.toString())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
              if (dataSnapshot.docs.isNotEmpty) {
                Map<String, dynamic> userMap =
                    dataSnapshot.docs[0].data() as Map<String, dynamic>;
                UserModel userModel = UserModel.fromMap(userMap);
                List<UserModel> searched = [];
                userModel.userId == UserDetails.userId.toString()
                    ? null
                    : searched.add(userModel);
                // searchController.clear();

                // notifyListeners();
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: searched.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatRoomModel =
                                await getChatRoomModel(searched[index]);
                            if (chatRoomModel != null) {
                              searchController.clear();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Chat_Room(
                                      targetUser: searched[index],
                                      chatRoom: chatRoomModel,
                                    ),
                                  ));
                            }
                          },
                          // trailing: Text(searched[index]),
                          leading: CircleAvatar(
                              radius: AppFontSize.font40,
                              backgroundImage:
                                  NetworkImage(searched[index].userImage!)),
                          title: Text(searched[index].userName!),
                          subtitle: Text(searched[index].userPhone!));
                    });
              } else {
                return Text("No Results found!");
              }
            } else if (snapshot.hasError) {
              return Text("An error occurred!");
            } else {
              return Text("No Result found");
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("participants.${UserDetails.userId.toString()}", isEqualTo: true)
        .where("participants.${targetUser.userId}", isEqualTo: true)
        .get();
    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel exestingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = exestingChatRoom;
    } else {
      ChatRoomModel newChatRoomModel = ChatRoomModel(
          chatRoomId: uuid.v1(),
          lastMessage: "",
          lastMessageTime: DateTime.now().toString(),
          participants: {
            UserDetails.userId.toString(): true,
            targetUser.userId.toString(): true,
          },
          user1: UserDetails.userPhone,
          user2: targetUser.userPhone!);
      chatRoom = newChatRoomModel;
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(newChatRoomModel.chatRoomId)
          .set(newChatRoomModel.toMap());
    }
    return chatRoom;
  }

  allUser() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chatRooms')
            .where("participants.${UserDetails.userId}", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
              return ListView.builder(
                itemCount: dataSnapshot.docs.length,
                itemBuilder: (context, index) {
                  ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                      dataSnapshot.docs[index].data() as Map<String, dynamic>);
                  Map<String, dynamic> participants =
                      chatRoomModel.participants!;
                  List<String> participantsKeys = participants.keys.toList();
                  participantsKeys.remove(UserDetails.userId);
                  return FutureBuilder(
                      future:
                          FirebaseHelper.getUserModelById(participantsKeys[0]),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          if (userData.data != null) {
                            UserModel targetUser = userData.data as UserModel;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: AppFontSize.font12),
                              child: ListTile(
                                subtitle: Text(
                                    chatRoomModel.lastMessage.toString() == ""
                                        ? ""
                                        : chatRoomModel.lastMessage.toString()),
                                contentPadding: EdgeInsets.all(0),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Chat_Room(
                                          targetUser: targetUser,
                                          chatRoom: chatRoomModel,
                                        ),
                                      ));
                                },
                                trailing: Text(chatRoomModel.lastMessage
                                            .toString() ==
                                        ""
                                    ? ""
                                    : DateFormat('h:mm a').format(
                                        DateTime.parse(
                                            chatRoomModel.lastMessageTime!))),
                                title: Text(targetUser.userName!),
                                leading: InkWell(
                                  onTap: () {
                                    showImageViewer(
                                        context,
                                        Image.network(targetUser.userImage!)
                                            .image,
                                        swipeDismissible: true,
                                        doubleTapZoomable: true);
                                  },
                                  child: CircleAvatar(
                                    radius: AppFontSize.font30,
                                    backgroundImage:
                                        NetworkImage(targetUser.userImage!),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        } else {
                          return SizedBox();
                        }
                      });
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return Center(child: Text("No Result found"));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  void sendMessage(ChatRoomModel chatRoomModel, UserModel targetModel) async {
    String msg = massgController.text.trim();
    massgController.clear();
    DateTime lastTime = DateTime.now();
    if (msg != "") {
      MessageModel newMessage = MessageModel(
          messageId: uuid.v1(),
          sender: UserDetails.userId,
          createdOn: lastTime,
          text: msg,
          seen: false,
          msgType: "text");
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomModel.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      chatRoomModel.lastMessage = msg;
      chatRoomModel.lastMessageTime = lastTime.toString();
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomModel.chatRoomId)
          .set(chatRoomModel.toMap());
      LocalNotificationService.getInstance()!.postNotification(
          UserDetails.userName, msg, targetModel.userFcmToken!, "message");
    }
  }

  getUserMessage(ChatRoomModel chatRoomModel) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chatRoomModel.chatRoomId)
            .collection("messages")
            .orderBy("createdOn", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
              return ListView.builder(
                reverse: true,
                itemCount: dataSnapshot.docs.length,
                itemBuilder: (context, index) {
                  MessageModel currentMessage = MessageModel.fomMap(
                      dataSnapshot.docs[index].data() as Map<String, dynamic>);

                  if (currentMessage.msgType == "video") {
                    videoController = VideoPlayerController.networkUrl(
                        Uri.parse(currentMessage.text!))
                      ..initialize();
                  }
                  return currentMessage.sender == UserDetails.userId.toString()
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 1.3,
                              child: Bubble(
                                  margin: BubbleEdges.only(
                                      bottom: AppFontSize.font10),
                                  padding: BubbleEdges.all(AppFontSize.font4),
                                  alignment: Alignment.topRight,
                                  nipWidth: AppFontSize.font16,
                                  color: AppColor.greenAccent,
                                  nipHeight: AppFontSize.font10,
                                  nip: BubbleNip.rightTop,
                                  child: currentMessage.msgType == "text"
                                      ? InkWell(
                                          onLongPress: () {
                                            showDeleteDialog(
                                                context,
                                                chatRoomModel,
                                                currentMessage,
                                                "message");
                                          },
                                          child: Text(
                                            currentMessage.text.toString(),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: AppFontSize.font16),
                                          ),
                                        )
                                      : currentMessage.msgType == "photo"
                                          ? InkWell(
                                              onLongPress: () {
                                                showDeleteDialog(
                                                    context,
                                                    chatRoomModel,
                                                    currentMessage,
                                                    "photo");
                                              },
                                              onTap: () {
                                                showImageViewer(
                                                    context,
                                                    Image.network(currentMessage
                                                            .text
                                                            .toString())
                                                        .image,
                                                    swipeDismissible: true,
                                                    doubleTapZoomable: true);
                                              },
                                              child: CachedNetworkImage(
                                                height: AppFontSize.font260,
                                                fit: BoxFit.fill,
                                                imageUrl: currentMessage.text
                                                    .toString(),
                                                progressIndicatorBuilder: (context,
                                                        url,
                                                        downloadProgress) =>
                                                    SizedBox(
                                                        width: 100,
                                                        child: Center(
                                                            child: CircularProgressIndicator(
                                                                value: downloadProgress
                                                                    .progress))),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image(
                                                        height:
                                                            AppFontSize.font260,
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_xZkeWTPAn1KbsTSI3mnVVdibJor8JJ12YA&usqp=CAU")),
                                              ),
                                            )
                                          : InkWell(
                                              onLongPress: () {
                                                showDeleteDialog(
                                                    context,
                                                    chatRoomModel,
                                                    currentMessage,
                                                    "video");
                                              },
                                              onTap: () {
                                                videoController.pause();
                                                videoController.value.isPlaying
                                                    ? videoController.pause()
                                                    : videoController.play();

                                                print(
                                                    "videoController:${videoController.value.isPlaying}==========$videoController");
                                              },
                                              child: Container(
                                                  height: 150,
                                                  child: VideoPlayer(
                                                      videoController)),
                                            )),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 1.3,
                              child: Bubble(
                                  margin: BubbleEdges.only(
                                      bottom: AppFontSize.font10),
                                  padding: BubbleEdges.all(AppFontSize.font4),
                                  alignment: Alignment.topLeft,
                                  nipWidth: AppFontSize.font16,
                                  color: Colors.black26,
                                  nipHeight: AppFontSize.font10,
                                  nip: BubbleNip.leftTop,
                                  child: currentMessage.msgType == "text"
                                      ? Text(
                                          currentMessage.text.toString(),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: AppFontSize.font16),
                                        )
                                      : Stack(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                showImageViewer(
                                                    context,
                                                    Image.network(currentMessage
                                                            .text
                                                            .toString())
                                                        .image,
                                                    swipeDismissible: true,
                                                    doubleTapZoomable: true);
                                              },
                                              child: CachedNetworkImage(
                                                height: AppFontSize.font260,
                                                fit: BoxFit.fill,
                                                imageUrl: currentMessage.text
                                                    .toString(),
                                                progressIndicatorBuilder: (context,
                                                        url,
                                                        downloadProgress) =>
                                                    SizedBox(
                                                        width: 100,
                                                        child: Center(
                                                            child: CircularProgressIndicator(
                                                                value: downloadProgress
                                                                    .progress))),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image(
                                                        height:
                                                            AppFontSize.font260,
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_xZkeWTPAn1KbsTSI3mnVVdibJor8JJ12YA&usqp=CAU")),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: InkWell(
                                                onTap: () {
                                                  UIHelper.snackMessage(context,
                                                      "Downloading....");
                                                  FileDownloader.downloadFile(
                                                      url: currentMessage.text
                                                          .toString(),
                                                      name: "Text Me",
                                                      onDownloadCompleted:
                                                          (path) {
                                                        final File file =
                                                            File(path);
                                                      });
                                                },
                                                child: CircleAvatar(
                                                  radius: AppFontSize.font20,
                                                  child: Icon(
                                                    Icons.download,
                                                    color: AppColor.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                            ),
                          ],
                        );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("An error occurred! Something went wrong"),
              );
            } else {
              return Center(
                child: Text("Say Hi to your new friend"),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<dynamic> showDeleteDialog(BuildContext context,
      ChatRoomModel chatRoomModel, MessageModel currentMessage, type) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete $type?"),
            content: Text("Delete for everyone"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () async {
                    FirebaseFirestore.instance
                        .collection("chatRooms")
                        .doc(chatRoomModel.chatRoomId)
                        .collection("messages")
                        .doc(currentMessage.messageId)
                        .delete();
                    Navigator.pop(context);
                  },
                  child: Text("Yes")),
            ],
          );
        });
  }

  void handleCamerGallery(
      context, ChatRoomModel chatRoomModel, UserModel targetModel) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Container(
          height: AppFontSize.font80,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    uploadVideo(context, ImageSource.gallery, chatRoomModel,
                        targetModel);
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.video_collection, size: AppFontSize.font40),
                ),
                InkWell(
                  onTap: () {
                    uploadImage(context, ImageSource.gallery, chatRoomModel,
                        targetModel);
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.collections,
                    size: AppFontSize.font40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future uploadImage(context, source, ChatRoomModel chatRoomModel,
      UserModel targetModel) async {
    final picker = ImagePicker();
    await picker.pickImage(source: source).then((xFile) {
      if (xFile != null) {
        sendFile = File(xFile.path);
      }
    });
    String fileName = Uuid().v1();
    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(sendFile!);
    String imageUrl = await uploadTask.ref.getDownloadURL();
    if (imageUrl.trim().isNotEmpty) {
      DateTime lastTime = DateTime.now();

      MessageModel newMessage = MessageModel(
          messageId: uuid.v1(),
          sender: UserDetails.userId,
          createdOn: lastTime,
          text: imageUrl.trim().toString(),
          seen: false,
          msgType: "photo");
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomModel.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());
      chatRoomModel.lastMessage = "photo";
      chatRoomModel.lastMessageTime = lastTime.toString();
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomModel.chatRoomId)
          .set(chatRoomModel.toMap());
      LocalNotificationService.getInstance()!.postNotification(
          "Message", "Photo", targetModel.userFcmToken!, "message");
      imageUrl = '';
      sendFile = null;
    }
  }

  Future uploadVideo(context, source, ChatRoomModel chatRoomModel,
      UserModel targetModel) async {
    final picker = ImagePicker();
    await picker.pickVideo(source: source).then((xFile) {
      if (xFile != null) {
        sendFile = File(xFile.path);
      }
    });
    String fileName = Uuid().v1();
    var ref =
        FirebaseStorage.instance.ref().child('video').child("$fileName.jpg");
    var uploadTask = await ref.putFile(sendFile!);
    String videoUrl = await uploadTask.ref.getDownloadURL();
    if (videoUrl.trim().isNotEmpty) {
      DateTime lastTime = DateTime.now();

      MessageModel newMessage = MessageModel(
          messageId: uuid.v1(),
          sender: UserDetails.userId,
          createdOn: lastTime,
          text: videoUrl.trim().toString(),
          seen: false,
          msgType: "video");
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomModel.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());
      chatRoomModel.lastMessage = "video";
      chatRoomModel.lastMessageTime = lastTime.toString();
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomModel.chatRoomId)
          .set(chatRoomModel.toMap());
      LocalNotificationService.getInstance()!.postNotification(
          "Message", "Video", targetModel.userFcmToken!, "message");
      videoUrl = '';
      sendFile = null;
    }
  }
}

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String Id) async {
    UserModel? userModel;

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(Id).get();

    if (docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}
