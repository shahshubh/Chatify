import 'package:Chatify/constants.dart';
import 'package:Chatify/enum/message_type.dart';
import 'package:Chatify/utils/utils.dart';
import 'package:Chatify/widgets/FullImageWidget.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';

class MessageItem extends StatelessWidget {
  final int index;
  final DocumentSnapshot document;
  final List listMessage;
  final String currUserId;
  final String receiverAvatar;
  final BuildContext context;
  final Function onDeleteMsg;

  MessageItem(
      {@required this.index,
      @required this.document,
      @required this.currUserId,
      @required this.receiverAvatar,
      @required this.context,
      @required this.onDeleteMsg,
      @required this.listMessage});

  @override
  Widget build(BuildContext context) {
    bool isLastMsgLeft(int index) {
      if ((index > 0 && listMessage != null) &&
              listMessage[index - 1]["idFrom"] == currUserId ||
          index == 0) {
        return true;
      } else {
        return false;
      }
    }

    bool isLastMsgRight(int index) {
      if ((index > 0 && listMessage != null) &&
              listMessage[index - 1]["idFrom"] != currUserId ||
          index == 0) {
        return true;
      } else {
        return false;
      }
    }

    bool isNewMsg(int index) {
      if (index == (listMessage.length - 1)) {
        return true;
      }
      DateTime curr = DateTime.fromMillisecondsSinceEpoch(
          int.parse(listMessage[index]["timestamp"]));
      DateTime prev = DateTime.fromMillisecondsSinceEpoch(
          int.parse(listMessage[index + 1]["timestamp"]));
      if (curr.year == prev.year &&
          curr.month == prev.month &&
          curr.day == prev.day) {
        return false;
      } else {
        return true;
      }
    }

    bool isToday(int index) {
      DateTime today = DateTime.now();
      DateTime curr = DateTime.fromMillisecondsSinceEpoch(
          int.parse(listMessage[index]["timestamp"]));
      if (curr.day == today.day) {
        return true;
      } else {
        return false;
      }
    }

    bool isYesterday(int index) {
      DateTime today = DateTime.now();
      DateTime curr = DateTime.fromMillisecondsSinceEpoch(
          int.parse(listMessage[index]["timestamp"]));
      if (curr.day == (today.day - 1)) {
        return true;
      } else {
        return false;
      }
    }

    //Logged User Messages - right side
    if (document["idFrom"] == currUserId) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            isNewMsg(index)
                ? Bubble(
                    margin: BubbleEdges.only(top: 20, bottom: 20),
                    alignment: Alignment.center,
                    color: Color.fromRGBO(212, 234, 244, 1.0),
                    child: Text(
                        isToday(index)
                            ? "TODAY"
                            : isYesterday(index)
                                ? "YESTERDAY"
                                : DateFormat("dd MMMM yyy").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document["timestamp"]))),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.0)),
                  )
                : Container(),

            Row(
              children: [
                document["type"] == Utils.msgToNum(MessageType.Deleted)
                    ? Container(
                        child: Bubble(
                        padding: BubbleEdges.all(10),
                        margin: BubbleEdges.only(top: 5),
                        alignment: Alignment.topRight,
                        // nip: BubbleNip.rightTop,
                        color: kPrimaryColor,
                        child: Row(
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.4),
                              child: Text(
                                document["content"],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Text(
                                DateFormat("hh:mm aa").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document["timestamp"]))),
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.italic),
                              ),
                            )
                          ],
                        ),
                      ))

                    // Text Msg
                    : FocusedMenuHolder(
                        blurSize: 0,
                        menuWidth: MediaQuery.of(context).size.width * 0.5,
                        duration: Duration(milliseconds: 200),
                        onPressed: () {},
                        bottomOffsetHeight: 100,
                        menuItems: <FocusedMenuItem>[
                          FocusedMenuItem(
                              title: Text(
                                "Delete",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              trailingIcon: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                onDeleteMsg(document);
                              }),
                        ],
                        child: Container(
                          child: document["type"] ==
                                  Utils.msgToNum(MessageType.Text)
                              ? Bubble(
                                  padding: BubbleEdges.all(10),
                                  margin: BubbleEdges.only(top: 5),
                                  alignment: Alignment.topRight,
                                  // nip: BubbleNip.rightTop,
                                  color: kPrimaryColor,
                                  child: Row(
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4),
                                        child: Text(
                                          document["content"],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 10.0, top: 5.0),
                                        child: Text(
                                          DateFormat("hh:mm aa").format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  int.parse(
                                                      document["timestamp"]))),
                                          style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12.0,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      )
                                    ],
                                  ),
                                )

                              // Image Msg
                              : document["type"] ==
                                      Utils.msgToNum(MessageType.Image)
                                  ? Container(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FullPhoto(
                                                          url: document[
                                                              "content"])));
                                        },
                                        child: Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        kPrimaryColor),
                                              ),
                                              width: 200.0,
                                              height: 200.0,
                                              padding: EdgeInsets.all(70.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Material(
                                              child: Image.asset(
                                                "images/img_not_available.jpeg",
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              clipBehavior: Clip.hardEdge,
                                            ),
                                            imageUrl: document["content"],
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        // onPressed: () {
                                        //   Navigator.push(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //           builder: (context) => FullPhoto(
                                        //               url: document["content"])));
                                        // },
                                      ),
                                      // margin: EdgeInsets.only(bottom: 10.0),
                                    )

                                  // GIF Msg
                                  : document["type"] ==
                                          Utils.msgToNum(MessageType.Gif)
                                      ? Container(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullPhoto(
                                                              url: document[
                                                                  "content"])));
                                            },
                                            child: Material(
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    Container(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            kPrimaryColor),
                                                  ),
                                                  width: 200.0,
                                                  height: 200.0,
                                                  padding: EdgeInsets.all(70.0),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Material(
                                                  child: Image.asset(
                                                    "images/img_not_available.jpeg",
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  clipBehavior: Clip.hardEdge,
                                                ),
                                                imageUrl: document["content"],
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          // child: Image.network(
                                          //   document['content'],
                                          //   headers: {'accept': 'image/*'},
                                          //   width: 200.0,
                                          //   height: 200.0,
                                          // ),
                                          // child: Image.asset(
                                          //   "images/${document['content']}.gif",
                                          //   width: 100.0,
                                          //   height: 100.0,
                                          //   fit: BoxFit.cover,
                                          // ),
                                          // margin: EdgeInsets.only(bottom: 10.0),
                                        )
                                      : Container(
                                          child: Image.asset(
                                            "images/${document['content']}.gif",
                                            width: 100.0,
                                            height: 100.0,
                                            fit: BoxFit.cover,
                                          ),
                                          margin: EdgeInsets.only(bottom: 10.0),
                                        ),
                        ),
                      ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),

            //MSG TIME
            document["type"] != Utils.msgToNum(MessageType.Text) &&
                    document["type"] != Utils.msgToNum(MessageType.Deleted)
                ? Container(
                    child: Text(
                      DateFormat("hh:mm aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document["timestamp"]))),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(right: 5.0, top: 10.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }

    //Other User - Left Side
    else {
      return Container(
        child: Column(
          children: [
            isNewMsg(index)
                ? Bubble(
                    margin: BubbleEdges.only(top: 20, bottom: 20),
                    alignment: Alignment.center,
                    color: Color.fromRGBO(212, 234, 244, 1.0),
                    child: Text(
                        isToday(index)
                            ? "TODAY"
                            : isYesterday(index)
                                ? "YESTERDAY"
                                : DateFormat("dd MMMM yyy").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document["timestamp"]))),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.0)),
                  )
                : Container(),

            Row(
              children: [
                // DISPLAY RECIEVER PROFILE IMAGE
                isLastMsgLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: receiverAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35.0,
                      ),

                document["type"] == Utils.msgToNum(MessageType.Deleted)
                    ? Container(
                        child: Bubble(
                        padding: BubbleEdges.all(10),
                        margin: BubbleEdges.only(top: 5),
                        alignment: Alignment.topRight,
                        // nip: BubbleNip.rightTop,
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.4),
                              child: Text(
                                document["content"],
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Text(
                                DateFormat("hh:mm aa").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document["timestamp"]))),
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.italic),
                              ),
                            )
                          ],
                        ),
                      ))
                    :
                    // DISPLAY MESSAGES
                    document["type"] == Utils.msgToNum(MessageType.Text)
                        ? Bubble(
                            padding: BubbleEdges.all(10),
                            margin: BubbleEdges.only(top: 5),
                            alignment: Alignment.topRight,
                            // nip: BubbleNip.leftTop,
                            color: Colors.grey[200],
                            child: Row(
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.4),
                                  child: Text(
                                    document["content"],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 10.0, top: 5.0),
                                  child: Text(
                                    DateFormat("hh:mm aa").format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(document["timestamp"]))),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.0,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ))

                        // Image Msg
                        : document["type"] == Utils.msgToNum(MessageType.Image)
                            ? Container(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullPhoto(
                                                url: document["content"])));
                                  },
                                  child: Material(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              kPrimaryColor),
                                        ),
                                        width: 200.0,
                                        height: 200.0,
                                        padding: EdgeInsets.all(70.0),
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Material(
                                        child: Image.asset(
                                          "images/img_not_available.jpeg",
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      imageUrl: document["content"],
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  // onPressed: () {
                                  //   Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //           builder: (context) => FullPhoto(
                                  //               url: document["content"])));
                                  // },
                                ),
                                // margin: EdgeInsets.only(left: 5.0),
                              )
                            : document["type"] ==
                                    Utils.msgToNum(MessageType.Gif)
                                ? Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FullPhoto(
                                                    url: document["content"])));
                                      },
                                      child: Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      kPrimaryColor),
                                            ),
                                            width: 200.0,
                                            height: 200.0,
                                            padding: EdgeInsets.all(70.0),
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Material(
                                            child: Image.asset(
                                              "images/img_not_available.jpeg",
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          imageUrl: document["content"],
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 10.0),
                                  )
                                : Container(
                                    child: Image.asset(
                                      "images/${document['content']}.gif",
                                      width: 100.0,
                                      height: 100.0,
                                      fit: BoxFit.cover,
                                    ),
                                    margin: EdgeInsets.only(
                                        bottom: 10.0, right: 10.0),
                                  )
              ],
            ),

            //Msg Time
            document["type"] != Utils.msgToNum(MessageType.Text) &&
                    document["type"] != Utils.msgToNum(MessageType.Deleted)
                ? Container(
                    child: Text(
                      DateFormat("hh:mm aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document["timestamp"]))),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 40.0, top: 10.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }
}
