import 'dart:async';
import 'dart:io';

import 'package:Chatify/components/chat_detail_page_appbar.dart';
import 'package:Chatify/components/msg_item.dart';
import 'package:Chatify/components/sticker_gif.dart';
import 'package:Chatify/configs/configs.dart';
import 'package:Chatify/constants.dart';
import 'package:Chatify/enum/message_type.dart';
import 'package:Chatify/resources/notification_methods.dart';
import 'package:Chatify/screens/CallScreens/pickup/pickup_layout.dart';
import 'package:Chatify/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Chatify/widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          title: 'Camera',
          image: Icon(
            Icons.camera,
            color: Colors.white,
          )),
      MenuItem(
          title: 'Gallery',
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
      case "Camera":
        getImage(isGallery: false);
        setState(() {
          isDisplaySticker = false;
        });
        break;

      case "Gallery":
        getImage(isGallery: true);
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
    setState(() {});
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
                    itemBuilder: (context, index) => MessageItem(
                        index: index,
                        document: snapshot.data.documents[index],
                        listMessage: listMessage,
                        currUserId: id,
                        receiverAvatar: receiverAvatar,
                        context: context,
                        onDeleteMsg: onDeleteMsg),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  onDeleteMsg(DocumentSnapshot document) {
    var docRef = Firestore.instance
        .collection("messages")
        .document(chatId)
        .collection(chatId)
        .document(document['timestamp']);
    if (document['timestamp'] == listMessage[0]['timestamp']) {
      //check type of document if image delete from storage
      if (document['type'] == Utils.msgToNum(MessageType.Image)) {
        FirebaseStorage.instance
            .getReferenceFromUrl(document["content"])
            .then((res) {
          res.delete().then((value) => print("Deleted"));
        });
      }
      // 𝘛𝘩𝘪𝘴 𝘮𝘦𝘴𝘴𝘢𝘨𝘦 𝘸𝘢𝘴 𝘥𝘦𝘭𝘦𝘵𝘦𝘥
      docRef.updateData({
        "content": "🚫 𝘛𝘩𝘪𝘴 𝘮𝘴𝘨 𝘸𝘢𝘴 𝘥𝘦𝘭𝘦𝘵𝘦𝘥",
        "type": Utils.msgToNum(MessageType.Deleted)
      });
      //change content and type of document
      //change from chatlist as well on both sides
      Firestore.instance
          .collection("Users")
          .document(id)
          .collection("chatList")
          .document(receiverId)
          .updateData({
        "content": "🚫 𝘛𝘩𝘪𝘴 𝘮𝘴𝘨 𝘸𝘢𝘴 𝘥𝘦𝘭𝘦𝘵𝘦𝘥",
        "type": Utils.msgToNum(MessageType.Deleted),
      });

      Firestore.instance
          .collection("Users")
          .document(receiverId)
          .collection("chatList")
          .document(id)
          .updateData({
        "content": "🚫 𝘛𝘩𝘪𝘴 𝘮𝘴𝘨 𝘸𝘢𝘴 𝘥𝘦𝘭𝘦𝘵𝘦𝘥",
        "type": Utils.msgToNum(MessageType.Deleted),
      });
    } else {
      //else
      //check type of document if image delete from storage getref from imageurl
      //change content and type of document
      if (document['type'] == Utils.msgToNum(MessageType.Image)) {
        FirebaseStorage.instance
            .getReferenceFromUrl(document["content"])
            .then((res) {
          res.delete().then((value) => print("Deleted"));
        });
      }
      docRef.updateData({
        "content": "🚫 𝘛𝘩𝘪𝘴 𝘮𝘴𝘨 𝘸𝘢𝘴 𝘥𝘦𝘭𝘦𝘵𝘦𝘥",
        "type": Utils.msgToNum(MessageType.Deleted),
      });
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
                onPressed: () =>
                    onSendMessage(textEditingController.text, MessageType.Text),
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

  void onSendMessage(String contentMsg, MessageType type) {
    setState(() {
      isDisplaySticker = false;
    });

    String currTime = DateTime.now().millisecondsSinceEpoch.toString();

    if (contentMsg != "") {
      String body = type == MessageType.Text
          ? contentMsg
          : type == MessageType.Image
              ? "Image"
              : type == MessageType.Gif ? "GIF" : "Sticker";
      String image = type == MessageType.Image ? contentMsg : "";

      sendPushNotification(
          preferences.getString('name'), recieverFcmToken, body, image);
      textEditingController.clear();

      Firestore.instance
          .collection("Users")
          .document(id)
          .collection("chatList")
          .document(receiverId)
          .setData({
        "id": receiverId,
        "content": contentMsg,
        "type": Utils.msgToNum(type),
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
        "type": Utils.msgToNum(type),
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
            "type": Utils.msgToNum(type)
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

  Future getImage({bool isGallery}) async {
    final pickedFile = await picker.getImage(
        source: isGallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 50);
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
      onSendMessage(gif.images.original.url, MessageType.Gif);
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
        onSendMessage(imageUrl, MessageType.Image);
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error: " + error);
    });
  }
}
