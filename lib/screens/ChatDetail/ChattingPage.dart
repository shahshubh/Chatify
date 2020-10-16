import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Chatify/components/chat_detail_page_appbar.dart';
import 'package:Chatify/components/sticker_gif.dart';
import 'package:Chatify/configs/agora_configs.dart';
import 'package:Chatify/constants.dart';
import 'package:Chatify/screens/CallScreens/pickup/pickup_layout.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Chatify/widgets/FullImageWidget.dart';
import 'package:Chatify/widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  final String currUserId;
  final String currUserAvatar;
  final String currUserName;

  Chat({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
    @required this.receiverName,
    @required this.currUserId,
    @required this.currUserAvatar,
    @required this.currUserName,
  });

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      uid: currUserId,
      scaffold: Scaffold(
        appBar: ChatDetailPageAppBar(
          receiverName: receiverName,
          receiverAvatar: receiverAvatar,
          receiverId: receiverId,
          currUserId: currUserId,
          currUserAvatar: currUserAvatar,
          currUserName: currUserName,
        ),
        body: ChatScreen(
          receiverId: receiverId,
          receiverAvatar: receiverAvatar,
        ),
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

  PopupMenu menu;
  GlobalKey gifBtnKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    isDisplaySticker = false;
    isLoading = false;

    chatId = "";
    readLocal();

    menu = PopupMenu(items: [
      MenuItem(
          title: 'Image',
          image: Icon(
            Icons.image,
            color: Colors.white,
          )),
      MenuItem(
          title: 'Sticker',
          image: Icon(
            Icons.insert_emoticon,
            color: Colors.white,
          )),
      MenuItem(
          title: 'GIF',
          image: Icon(
            Icons.gif,
            color: Colors.white,
          )),
    ], onClickMenu: onClickMenu, onDismiss: onDismiss, maxColumn: 4);
  }

  void stateChanged(bool isShow) {
    print('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void onClickMenu(MenuItemProvider item) {
    switch (item.menuTitle) {
      case "Image":
        getImage();
        setState(() {
          isDisplaySticker = false;
        });
        break;

      case "Sticker":
        getSticker();
        break;

      case "GIF":
        getGif();
        setState(() {
          isDisplaySticker = false;
        });
        break;
    }

    print('Click menu -> ${item.menuTitle}');
  }

  void onDismiss() {
    print('Menu is dismiss');
  }

  readLocal() async {
    Firestore.instance
        .collection("Users")
        .document(receiverId)
        .get()
        .then((datasnapshot) {
      // print(datasnapshot.data["name"]);
      // print(datasnapshot.data["fcmToken"]);
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
      String userToken, String body, String image) async {
    // print("SENDING PUSH NOTIFICATION");
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "notification": {
        "body": "$body",
        "title": "${preferences.getString('name')}",
        "image": image
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
      // print('test ok push CFM');
      return true;
    } else {
      // print(' CFM error');
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
    PopupMenu.context = context;
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
              StickerGif(gifName: "mimi1", onSendMessage: onSendMessage),
              StickerGif(gifName: "mimi2", onSendMessage: onSendMessage),
              StickerGif(gifName: "mimi3", onSendMessage: onSendMessage),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          //ROW 2
          Row(
            children: [
              StickerGif(gifName: "mimi4", onSendMessage: onSendMessage),
              StickerGif(gifName: "mimi5", onSendMessage: onSendMessage),
              StickerGif(gifName: "mimi6", onSendMessage: onSendMessage),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          //ROW 3
          Row(
            children: [
              StickerGif(gifName: "mimi7", onSendMessage: onSendMessage),
              StickerGif(gifName: "mimi8", onSendMessage: onSendMessage),
              StickerGif(gifName: "mimi9", onSendMessage: onSendMessage),
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
                // Text Msg
                document["type"] == 0
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
                            ),
                          ],
                        ),
                      )

                    // Image Msg
                    : document["type"] == 1
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
                        : document["type"] == 2
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
                              )
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),

            //MSG TIME
            document["type"] != 0
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

                // DISPLAY MESSAGES
                document["type"] == 0
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
                            ),
                          ],
                        ))

                    // Image Msg
                    : document["type"] == 1
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
                        : document["type"] == 2
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
                                margin:
                                    EdgeInsets.only(bottom: 10.0, right: 10.0),
                              )
              ],
            ),

            //Msg Time
            document["type"] != 0
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

  createInput() {
    return Container(
      child: Row(
        children: [
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                key: gifBtnKey,
                icon: Icon(Icons.attach_file),
                color: kPrimaryColor,
                onPressed: onAttachmentClick,
              ),
            ),
            color: Colors.white,
          ),

          // Material(
          //   child: Container(
          //     margin: EdgeInsets.symmetric(horizontal: 1.0),
          //     child: IconButton(
          //       icon: Icon(Icons.image),
          //       color: kPrimaryColor,
          //       onPressed: getImage,
          //     ),
          //   ),
          //   color: Colors.white,
          // ),
          // Material(
          //   child: Container(
          //     margin: EdgeInsets.symmetric(horizontal: 1.0),
          //     child: IconButton(
          //       icon: Icon(
          //         Icons.gif,
          //         size: 40,
          //       ),
          //       color: kPrimaryColor,
          //       onPressed: getGif,
          //       padding: EdgeInsets.only(bottom: 0.0),
          //     ),
          //   ),
          //   color: Colors.white,
          // ),
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
    //type=2 => GIF
    //type=3 => Sticker

    String currTime = DateTime.now().millisecondsSinceEpoch.toString();

    if (contentMsg != "") {
      String body = type == 0
          ? contentMsg
          : type == 1 ? "Image" : type == 2 ? "GIF" : "Sticker";
      String image = type == 1 ? contentMsg : "";

      callOnFcmApiSendPushNotifications(recieverFcmToken, body, image);
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
        "timestamp": currTime,
        "showCheck": true
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
        "timestamp": currTime,
        "showCheck": false
      }, merge: true);

      var docRef = Firestore.instance
          .collection("messages")
          .document(chatId)
          .collection(chatId)
          .document(currTime);
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          docRef,
          {
            "idFrom": id,
            "idTo": receiverId,
            "timestamp": currTime,
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

  void onAttachmentClick() {
    menu.show(widgetKey: gifBtnKey);
  }

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        isLoading = true;
      }
    });

    if (pickedFile != null) {
      uploadImageFile();
    }
  }

  Future getGif() async {
    final gif =
        await GiphyPicker.pickGif(context: context, apiKey: GIPHY_API_KEY);

    if (gif != null) {
      onSendMessage(gif.images.original.url, 2);
      print(gif.images.original.url);
    }
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
