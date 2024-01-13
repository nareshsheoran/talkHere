// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:bubble/bubble.dart';
import 'package:bubble/issue_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:whats_app/data_All/SharedPreferences.dart';
import 'package:whats_app/data_All/app_color.dart';
import 'package:whats_app/data_All/font_sizes.dart';
import 'package:whats_app/model/chat_room_model.dart';
import 'package:whats_app/model/user_model.dart';
import 'package:whats_app/provider/home_provider.dart';
import 'package:whats_app/provider/phone_provider.dart';

class Chat_Room extends StatefulWidget {
  final UserModel? targetUser;
  final ChatRoomModel? chatRoom;

  Chat_Room({
    Key? key,
    required this.targetUser,
    required this.chatRoom,
  }) : super(key: key);

  @override
  State<Chat_Room> createState() => _Chat_RoomState();
}

class _Chat_RoomState extends State<Chat_Room> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
              backgroundColor: AppColor.amber,
              centerTitle: true,
              title: ListTile(
                leading: Stack(children: [
                  CircleAvatar(
                    radius: AppFontSize.font24,
                    backgroundImage:
                        NetworkImage(widget.targetUser!.userImage!),
                  ),
                ]),
                title: Text(
                  widget.targetUser!.userName!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSize.font18,
                      color: AppColor.black),
                ),
                subtitle: Text(
                  widget.targetUser!.userPhone!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSize.font10,
                      color: AppColor.black),
                ),
              )),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Flexible(
                    child: provider.getUserMessage(widget.chatRoom!),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: AppFontSize.font50,
                        child: InkWell(
                            onTap: () {
                              provider.uploadImage(context, ImageSource.camera,
                                  widget.chatRoom!, widget.targetUser!);
                            },
                            child: Icon(
                              Icons.camera_enhance_rounded,
                              size: AppFontSize.font28,
                            )),
                      ),
                      SizedBox(width: AppFontSize.font8),
                      Container(
                        height: AppFontSize.font50,
                        child: InkWell(
                            onTap: () {
                              provider.handleCamerGallery(context,
                                  widget.chatRoom!, widget.targetUser!);
                            },
                            child: Icon(
                              Icons.photo_camera_back_outlined,
                              size: AppFontSize.font28,
                            )),
                      ),
                      SizedBox(width: AppFontSize.font8),
                      Flexible(
                        child: Card(
                          child: TextFormField(
                            // autofocus: true,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            controller: provider.massgController,
                            // maxLines: null,
                            maxLines: 5,
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.all(AppFontSize.font12),
                                hintText: "Messages.....",
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none)),
                          ),
                        ),
                      ),
                      SizedBox(width: AppFontSize.font8),
                      Container(
                        height: AppFontSize.font50,
                        child: InkWell(
                            onTap: () {
                              provider.sendMessage(
                                  widget.chatRoom!, widget.targetUser!);
                            },
                            child: Icon(
                              Icons.send,
                              size: AppFontSize.font28,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
