import 'package:Chatify/screens/ChatDetail/ChattingPage.dart';
import 'package:Chatify/widgets/StatusIndicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Chat(
            receiverId: widget.userId,
            receiverAvatar: widget.image,
            receiverName: widget.name,
            currUserId: currentuserid,
            currUserName: currentusername,
            currUserAvatar: currentuserphoto,
          );
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
