import 'package:Chatify/utils/call_utilites.dart';
import 'package:Chatify/widgets/StatusIndicator.dart';
import 'package:Chatify/utils/permissions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatDetailPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String receiverAvatar;
  final String receiverName;
  final String receiverId;

  final String currUserId;
  final String currUserAvatar;
  final String currUserName;

  ChatDetailPageAppBar({
    Key key,
    @required this.receiverAvatar,
    @required this.receiverName,
    @required this.receiverId,
    @required this.currUserAvatar,
    @required this.currUserName,
    @required this.currUserId,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 15,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(receiverAvatar),
                maxRadius: 20,
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      receiverName,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    StatusIndicator(
                      uid: receiverId,
                      screen: "chatDetailScreen",
                    )
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.video_call,
                  color: Colors.grey.shade700,
                ),
                onPressed: () async =>
                    await Permissions.cameraAndMicrophonePermissionsGranted()
                        ? CallUtils.dial(
                            currUserId: currUserId,
                            currUserName: currUserName,
                            currUserAvatar: currUserAvatar,
                            receiverId: receiverId,
                            receiverAvatar: receiverAvatar,
                            receiverName: receiverName,
                            context: context)
                        : {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
