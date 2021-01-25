import 'package:Chatify/constants.dart';
import 'package:Chatify/models/group.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'groupChattingPage.dart';

class ShowGroups extends StatefulWidget {
  final Groups group;

  ShowGroups({
    this.group,
  });
  @override
  _ShowGroupsState createState() => _ShowGroupsState();
}

class _ShowGroupsState extends State<ShowGroups> {
  String currentuserid;
  String currentusername;
  String currentuserphoto;
  SharedPreferences preferences;

  String lastMessageShort;

  // photourl = "https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg";
  String photourl ;
  

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
    if(widget.group.lastMessage == null) return "New";
    DateTime today = DateTime.now();
    DateTime curr = DateTime.fromMillisecondsSinceEpoch(
        int.parse(widget.group.lastMessageTime));
    if (curr.year == today.year &&
        curr.month == today.month &&
        curr.day == today.day) {
      return DateFormat("hh:mm aa").format(DateTime.fromMillisecondsSinceEpoch(
          int.parse(widget.group.lastMessageTime)));
    } else if (curr.year == today.year &&
        curr.month == today.month &&
        curr.day == (today.day - 1)) {
      return "Yesterday";
    } else {
      return DateFormat("dd / MM / yyyy").format(
          DateTime.fromMillisecondsSinceEpoch(
              int.parse(widget.group.lastMessageTime)));
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.group.photoUrl != "" ? photourl = widget.group.photoUrl : photourl = defaultpic; 
    if(widget.group.lastMessageType == 0){
      if(widget.group.lastMessage != "" && widget.group.lastMessage.length > 20){
        lastMessageShort = widget.group.lastMessage.substring(0,19) + "...";
      }
    }
    
          return InkWell(
            onTap: () {
           
              Navigator.push(context,new MaterialPageRoute(builder: (context) {
                return GroupChat(
                 
                  group : widget.group,
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
                                  NetworkImage(photourl),
                              maxRadius: 30,
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
                                Text(widget.group.name),
                                SizedBox(
                                  height: 6,
                                ),
                                secondaryText(),
                                
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

                    ),
                  )
                ],
              ),
            ),
          );
        }
    //   },
    // );
  // }

  Widget secondaryText(){
    String last_Sender ;
    widget.group.lastSender == currentusername ? last_Sender = "You : " : last_Sender = widget.group.lastSender; 
    // print("1");
    if(widget.group.lastMessage == null || widget.group.lastMessage == "" ){
      // print("2 ${widget.group.lastMessage}");
      String shortDes = widget.group.description;
      if(widget.group.description!=null && widget.group.description.length > 37 ){
        shortDes = widget.group.description.substring(0,26) + "...";
      }
      // print("$shortDes");
      return RichText(
        text :
         TextSpan(
            text: "$shortDes" ,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500
            ),

          ),
      );
    }
    else{
      
      int size = 33 - widget.group.lastSender.length;
      return RichText(
          text:
            TextSpan(children: [
              TextSpan(
              text: "$last_Sender" ,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500
              ),

            ),
        
        TextSpan(
          text: widget.group.lastMessageType == 3
              ? "Sticker"
              : widget.group.lastMessageType == 2
                  ? "GIF"
                  : widget.group.lastMessageType == 1
                      ? "IMAGE"
                      : widget.group.lastMessageType == -1
                          ? widget.group.lastMessage
                              .toString()
                          : widget.group.lastMessage
                                      .toString()
                                      .length >
                                  size
                              ? widget.group.lastMessage
                                      .toString()
                                      .substring(
                                          0, size) +
                                  "..."
                              : widget.group.lastMessage
                                  .toString(),
          style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500),
        ),
      ])
      );
    }
  }
}
