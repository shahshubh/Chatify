import 'package:Chatify/screens/ChatDetail/ChattingPage.dart';
import 'package:Chatify/widgets/StatusIndicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatChatsScreen extends StatefulWidget {
  final DocumentSnapshot data;

  ChatChatsScreen({
    @required this.data,
  });
  @override
  _ChatChatsScreenState createState() => _ChatChatsScreenState();
}

class _ChatChatsScreenState extends State<ChatChatsScreen> {
  String currentuserid;
  String currentusername;
  String currentuserphoto;
  SharedPreferences preferences;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrUser();
  }

  getCurrUser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid");
      currentusername = preferences.getString("name");
      currentuserphoto = preferences.getString("photo");
    });
  }

  String checkDate() {
    DateTime today = DateTime.now();
    DateTime curr = DateTime.fromMillisecondsSinceEpoch(
        int.parse(widget.data["timestamp"]));
    if (curr.year == today.year &&
        curr.month == today.month &&
        curr.day == today.day) {
      return DateFormat("hh:mm aa").format(DateTime.fromMillisecondsSinceEpoch(
          int.parse(widget.data["timestamp"])));
    } else if (curr.year == today.year &&
        curr.month == today.month &&
        curr.day == (today.day - 1)) {
      return "Yesterday";
    } else {
      return DateFormat("dd / MM / yyyy").format(
          DateTime.fromMillisecondsSinceEpoch(
              int.parse(widget.data["timestamp"])));
    }
  }

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
              // child: Text("User details not found"),
              );
        } else {
          return InkWell(
            onTap: () {
              // print(widget.data["content"]);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Chat(
                  receiverId: snapshot.data["uid"],
                  receiverAvatar: snapshot.data["photoUrl"],
                  receiverName: snapshot.data["name"],
                  currUserId: currentuserid,
                  currUserName: currentusername,
                  currUserAvatar: currentuserphoto,
                );
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
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data["photoUrl"]),
                              maxRadius: 30,
                            ),
                            Positioned(
                              left: 0,
                              top: 30,
                              child: StatusIndicator(
                                uid: widget.data["id"],
                                screen: "chatListScreen",
                              ),
                            ),
                          ],
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
                                RichText(
                                    text: TextSpan(children: [
                                  widget.data["showCheck"]
                                      ? WidgetSpan(
                                          child: Container(
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.blueAccent,
                                            size: 16,
                                          ),
                                          padding: EdgeInsets.only(right: 5),
                                        ))
                                      : TextSpan(),
                                  TextSpan(
                                    text: widget.data["type"] == 3
                                        ? "Sticker"
                                        : widget.data["type"] == 2
                                            ? "GIF"
                                            : widget.data["type"] == 1
                                                ? "IMAGE"
                                                : widget.data["type"] == -1
                                                    ? widget.data["content"]
                                                        .toString()
                                                    : widget.data["content"]
                                                                .toString()
                                                                .length >
                                                            30
                                                        ? widget.data["content"]
                                                                .toString()
                                                                .substring(
                                                                    0, 30) +
                                                            "..."
                                                        : widget.data["content"]
                                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500),
                                  ),
                                ])),
                                // Text(
                                //   widget.data["type"] == 3
                                //       ? "Sticker"
                                //       : widget.data["type"] == 2
                                //           ? "GIF"
                                //           : widget.data["type"] == 1
                                //               ? "IMAGE"
                                //               : widget.data["content"]
                                //                           .toString()
                                //                           .length >
                                //                       30
                                //                   ? widget.data["content"]
                                //                           .toString()
                                //                           .substring(0, 30) +
                                //                       "..."
                                //                   : widget.data["content"]
                                //                       .toString(),
                                //   style: TextStyle(
                                //       fontSize: 14,
                                //       color: Colors.grey.shade500),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    checkDate(),
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
