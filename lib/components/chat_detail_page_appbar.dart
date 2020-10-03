import 'package:Chatify/Widgets/StatusIndicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatDetailPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String receiverAvatar;
  final String receiverName;
  final String receiverId;

  ChatDetailPageAppBar(
      {Key key,
      @required this.receiverAvatar,
      @required this.receiverName,
      @required this.receiverId});
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
                    // Text(
                    //   "Online",
                    //   style: TextStyle(color: Colors.green, fontSize: 12),
                    // ),
                  ],
                ),
              ),
              // Icon(
              //   Icons.more_vert,
              //   color: Colors.grey.shade700,
              // ),
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
