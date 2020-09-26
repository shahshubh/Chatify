// import 'package:chat_app/modules/chat_detail_page.dart';
import 'package:ChatApp/Screens/ChattingPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatUsersList extends StatefulWidget {
  final String name;
  final String secondaryText;
  final String image;
  final String time;
  final bool isMessageRead;
  final String userId;
  final String screen;
  ChatUsersList(
      {@required this.name,
      @required this.secondaryText,
      @required this.image,
      @required this.time,
      @required this.isMessageRead,
      @required this.screen,
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
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.image == null
                        ? "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
                        : widget.image),
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
                          Text(widget.name),
                          SizedBox(
                            height: 6,
                          ),
                          widget.screen == "UserListScreen"
                              ? Text(
                                  DateFormat("dd MMMM, yyyy").format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(widget.time))),
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500),
                                )
                              : Text(
                                  widget.secondaryText,
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
            widget.screen == "ChatsScreen"
                ? Text(
                    DateFormat("hh:mm aa").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(widget.time))),
                    style: TextStyle(
                        fontSize: 12,
                        color: widget.isMessageRead
                            ? Colors.pink
                            : Colors.grey.shade500),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
