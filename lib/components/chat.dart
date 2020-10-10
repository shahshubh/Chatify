import 'package:Chatify/Screens/ChatDetail/ChattingPage.dart';
import 'package:Chatify/Widgets/StatusIndicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatUsersList extends StatefulWidget {
  final String name;
  // final String secondaryText;
  final String image;
  final String time;
  final bool isMessageRead;
  final String userId;
  final String email;
  // final String screen;
  ChatUsersList(
      {@required this.name,
      // @required this.secondaryText,
      @required this.image,
      @required this.time,
      @required this.isMessageRead,
      @required this.email,
      // @required this.screen,
      @required this.userId});
  @override
  _ChatUsersListState createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Chat(
              receiverId: widget.userId,
              receiverAvatar: widget.image,
              receiverName: widget.name);
        }));
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.image),
                        maxRadius: 30,
                      ),
                      Positioned(
                        left: 0,
                        top: 30,
                        child: StatusIndicator(
                          uid: widget.userId,
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
                          Text(widget.name),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.email,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic),
                          )
                          // Text(
                          //   "Joined on " +
                          //       DateFormat("dd MMMM, yyyy").format(
                          //           DateTime.fromMillisecondsSinceEpoch(
                          //               int.parse(widget.time))),
                          //   style: TextStyle(
                          //       fontSize: 14,
                          //       color: Colors.grey.shade500,
                          //       fontStyle: FontStyle.italic),
                          // )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // widget.screen == "ChatsScreen"
            //     ? Text(
            //         "Joined at " +
            //             DateFormat("hh:mm aa").format(
            //                 DateTime.fromMillisecondsSinceEpoch(
            //                     int.parse(widget.time))),
            //         style: TextStyle(
            //             fontStyle: FontStyle.italic,
            //             fontSize: 12,
            //             color: widget.isMessageRead
            //                 ? Colors.pink
            //                 : Colors.grey.shade500),
            //       )
            //     : Container()
          ],
        ),
      ),
    );
  }
}
