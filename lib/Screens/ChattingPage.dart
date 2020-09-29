import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ChatApp/components/chat_detail_page_appbar.dart';
import 'package:ChatApp/constants.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ChatApp/Widgets/FullImageWidget.dart';
import 'package:ChatApp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;
  Chat(
      {Key key,
      @required this.receiverId,
      @required this.receiverAvatar,
      @required this.receiverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.lightBlue,
      //   actions: [
      //     Padding(
      //       padding: EdgeInsets.all(0.0),
      //       child: CircleAvatar(
      //         backgroundColor: Colors.black,
      //         backgroundImage: CachedNetworkImageProvider(receiverAvatar),
      //       ),
      //     ),
      //   ],
      //   iconTheme: IconThemeData(color: Colors.white),
      //   title: Text(
      //     receiverName,
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   centerTitle: true,
      // ),
      appBar: ChatDetailPageAppBar(
          receiverName: receiverName,
          receiverAvatar: receiverAvatar,
          receiverId: receiverId),
      body: ChatScreen(
        receiverId: receiverId,
        receiverAvatar: receiverAvatar,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;
  ChatScreen({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
  }) : super(key: key);

  @override
  State createState() => ChatScreenState(
        receiverId: receiverId,
        receiverAvatar: receiverAvatar,
      );
}

class ChatScreenState extends State<ChatScreen> {
  final String receiverId;
  final String receiverAvatar;

  ChatScreenState({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
  });

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;

  File imageFile;
  String imageUrl;
  final picker = ImagePicker();

  String chatId;
  String id;
  SharedPreferences preferences;

  String recieverFcmToken;

  var listMessage = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    isDisplaySticker = false;
    isLoading = false;

    chatId = "";
    readLocal();
  }

  readLocal() async {
    Firestore.instance
        .collection("Users")
        .document(receiverId)
        .get()
        .then((datasnapshot) {
      print(datasnapshot.data["name"]);
      print(datasnapshot.data["fcmToken"]);
      setState(() {
        recieverFcmToken = datasnapshot.data["fcmToken"];
      });
    });
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("uid") ?? "";
    if (id.hashCode <= receiverId.hashCode) {
      chatId = '$id-$receiverId';
    } else {
      chatId = '$receiverId-$id';
    }

    Firestore.instance
        .collection("Users")
        .document(id)
        .updateData({'chattingWith': receiverId});
    setState(() {});
  }

  Future<bool> callOnFcmApiSendPushNotifications(
      String userToken, String body) async {
    print("SENDING PUSH NOTIFICATION");
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "notification": {
        "body": "$body",
        "title": "${preferences.getString('name')}"
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": "$userToken"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          "key=AAAAeXmVt7g:APA91bFMfbZftiYhpPWy3OdQ-XoMYm8f7BEOuNblHFpueqFRqoPmoTVUH3UrfUPI5d22bshwQKuPCqT0LB3gxfzAkf5cqpaxSEvfRtPHt7SWpbLt9FOACfa55J0dGHlP62RQRpgf9sJ6" // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(postUrl,
        body: jsonEncode(data),
        // encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      print('test ok push CFM');
      return true;
    } else {
      print(' CFM error');
      // on failure do sth
      return false;
    }
  }

  onFocusChange() {
    // Hide sticker whenever keypad appears
    if (focusNode.hasFocus) {
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: [
          Column(
            children: [
              createListMessages(),
              //show stickers
              (isDisplaySticker ? createStickers() : Container()),
              createInput(),
            ],
          ),
          createLoading(),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  createLoading() {
    return Positioned(
      child: isLoading ? oldcircularprogress() : Container(),
    );
  }

  Future<bool> onBackPress() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  createStickers() {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              FlatButton(
                onPressed: () => onSendMessage("mimi1", 2),
                child: Image.asset(
                  "images/mimi1.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi2", 2),
                child: Image.asset(
                  "images/mimi2.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi3", 2),
                child: Image.asset(
                  "images/mimi3.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          //ROW 2

          Row(
            children: [
              FlatButton(
                onPressed: () => onSendMessage("mimi4", 2),
                child: Image.asset(
                  "images/mimi4.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi5", 2),
                child: Image.asset(
                  "images/mimi5.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi6", 2),
                child: Image.asset(
                  "images/mimi6.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          //ROW 3

          Row(
            children: [
              FlatButton(
                onPressed: () => onSendMessage("mimi7", 2),
                child: Image.asset(
                  "images/mimi7.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi8", 2),
                child: Image.asset(
                  "images/mimi8.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage("mimi9", 2),
                child: Image.asset(
                  "images/mimi9.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  createListMessages() {
    return Flexible(
      child: chatId == ""
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(kPrimaryColor)),
            )
          : StreamBuilder(
              stream: Firestore.instance
                  .collection("messages")
                  .document(chatId)
                  .collection(chatId)
                  .orderBy("timestamp", descending: true)
                  // .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kPrimaryColor)),
                  );
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        createItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  bool isLastMsgLeft(int index) {
    if ((index > 0 && listMessage != null) &&
            listMessage[index - 1]["idFrom"] == id ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 && listMessage != null) &&
            listMessage[index - 1]["idFrom"] != id ||
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

  Widget createItem(int index, DocumentSnapshot document) {
    //Logged User Messages - right side
    if (document["idFrom"] == id) {
      return Container(
        child: Column(
          children: [
            isNewMsg(index)
                ? Bubble(
                    margin: BubbleEdges.only(top: 10, bottom: 10),
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
                // Text Msg
                document["type"] == 0
                    ? Bubble(
                        padding: BubbleEdges.all(10),
                        margin: BubbleEdges.only(top: 5),
                        alignment: Alignment.topRight,
                        nip: BubbleNip.rightTop,
                        color: kPrimaryColor,
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: document["content"],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ]),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Text(
                                DateFormat("hh:mm:aa").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document["timestamp"]))),
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      )

                    // Container(
                    //     child: Text(
                    //       document["content"],
                    //       style: TextStyle(
                    //           color: Colors.white, fontWeight: FontWeight.w500),
                    //     ),
                    //     padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    //     width: 200.0,
                    //     decoration: BoxDecoration(
                    //         color: kPrimaryColor,
                    //         borderRadius: BorderRadius.circular(8.0)),
                    //     margin: EdgeInsets.only(
                    //       // bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                    //       right: 10.0,
                    //     ))
                    // Image Msg
                    : document["type"] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(kPrimaryColor),
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
                                    borderRadius: BorderRadius.circular(8.0),
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
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document["content"])));
                              },
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          )

                        // GIF Msg
                        : Container(
                            child: Image.asset(
                              "images/${document['content']}.gif",
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),

            //MSG TIME
            // Container(
            //   child: Text(
            //     DateFormat("hh:mm aa").format(
            //         DateTime.fromMillisecondsSinceEpoch(
            //             int.parse(document["timestamp"]))),
            //     style: TextStyle(
            //         color: Colors.grey,
            //         fontSize: 12.0,
            //         fontStyle: FontStyle.italic),
            //   ),
            //   margin: EdgeInsets.only(right: 10.0, top: 10.0, bottom: 5.0),
            // )
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
                    margin: BubbleEdges.only(top: 10, bottom: 10),
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

                // DISPLAY MESSAGES
                document["type"] == 0
                    ? Bubble(
                        padding: BubbleEdges.all(10),
                        margin: BubbleEdges.only(top: 5, left: 5),
                        alignment: Alignment.topRight,
                        nip: BubbleNip.leftTop,
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: document["content"],
                                  style: TextStyle(color: Colors.black),
                                ),
                              ]),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Text(
                                DateFormat("hh:mm:aa").format(
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

                    //  Container(
                    //     child: Text(
                    //       document["content"],
                    //       style: TextStyle(
                    //           color: Colors.black, fontWeight: FontWeight.w400),
                    //     ),
                    //     padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    //     width: 200.0,
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey[200],
                    //       borderRadius: BorderRadius.circular(8.0),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(0.5),
                    //     spreadRadius: 1,
                    //     blurRadius: 2,
                    //     offset:
                    //         Offset(0, 1), // changes position of shadow
                    //   ),
                    // ],
                    // ),
                    // margin: EdgeInsets.only(left: 10.0))

                    // Image Msg
                    : document["type"] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(kPrimaryColor),
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
                                    borderRadius: BorderRadius.circular(8.0),
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
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document["content"])));
                              },
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
                                bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            //Msg Time
            // Container(
            //   child: Text(
            //     DateFormat("hh:mm:aa").format(
            //         DateTime.fromMillisecondsSinceEpoch(
            //             int.parse(document["timestamp"]))),
            //     style: TextStyle(
            //         color: Colors.grey,
            //         fontSize: 12.0,
            //         fontStyle: FontStyle.italic),
            //   ),
            //   margin: EdgeInsets.only(left: 50.0, top: 10.0, bottom: 5.0),
            // )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  createInput() {
    return Container(
      child: Row(
        children: [
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: kPrimaryColor,
                onPressed: getImage,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(
                  Icons.insert_emoticon,
                ),
                color: kPrimaryColor,
                onPressed: getSticker,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                    hintText: "Type message...",
                    hintStyle: TextStyle(color: Colors.grey)),
                focusNode: focusNode,
              ),
            ),
          ),

          //SEND MESSAGE BUTTON
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: kPrimaryColor,
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            ),
            color: Colors.white,
          )
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
        color: Colors.white,
      ),
    );
  }

  void onSendMessage(String contentMsg, int type) {
    //type=0 => text Msg
    //type=1 => Image File
    //type=2 => Sticker

    if (contentMsg != "") {
      String body = type == 0 ? contentMsg : type == 1 ? "Image" : "GIF";

      callOnFcmApiSendPushNotifications(recieverFcmToken, body);
      textEditingController.clear();

      Firestore.instance
          .collection("Users")
          .document(id)
          .collection("chatList")
          .document(receiverId)
          .setData({
        "id": receiverId,
        "content": contentMsg,
        "type": type,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      }, merge: true);

      Firestore.instance
          .collection("Users")
          .document(receiverId)
          .collection("chatList")
          .document(id)
          .setData({
        "id": id,
        "content": contentMsg,
        "type": type,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      }, merge: true);

      var docRef = Firestore.instance
          .collection("messages")
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          docRef,
          {
            "idFrom": id,
            "idTo": receiverId,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "Empty message cannot be sent");
    }
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        isLoading = true;
      }
    });
    uploadImageFile();
  }

  Future uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("Chat Images").child(fileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error: " + error);
    });
  }
}
