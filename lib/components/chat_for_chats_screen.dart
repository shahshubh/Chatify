// import 'package:chat_app/modules/chat_detail_page.dart';
import 'package:ChatApp/Screens/ChattingPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatChatsScreen extends StatefulWidget {
  final DocumentSnapshot data;

  ChatChatsScreen({
    @required this.data,
  });
  @override
  _ChatChatsScreenState createState() => _ChatChatsScreenState();
}

class _ChatChatsScreenState extends State<ChatChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("Users")
          .document(widget.data["id"])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            child: Text("User details not found"),
          );
        } else {
          return InkWell(
            onTap: () {
              print(widget.data["content"]);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Chat(
                    receiverId: snapshot.data["uid"],
                    receiverAvatar: snapshot.data["photoUrl"],
                    receiverName: snapshot.data["name"]);
              }));
            },
            child: Container(
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data["photoUrl"]),
                          maxRadius: 30,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(snapshot.data["name"]),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  widget.data["content"],
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat("hh:mm aa").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(widget.data["timestamp"]))),
                    style: TextStyle(
                      fontSize: 12,
                      // color: widget.isMessageRead
                      //     ? Colors.pink
                      //     : Colors.grey.shade500
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
