import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:Chatify/components/group_detail_page_appbar.dart';
import 'package:Chatify/components/sticker_gif.dart';
import 'package:Chatify/configs/configs.dart';
import 'package:Chatify/constants.dart';
import 'package:Chatify/models/groupMessages.dart';
import 'package:Chatify/models/user.dart';
import 'package:Chatify/services/database_service.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:Chatify/widgets/FullImageWidget.dart';
import 'package:Chatify/widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:Chatify/models/group.dart';

import 'add_admin.dart';
import 'add_participants.dart';
import 'create_new_group.dart';

class GroupChat extends StatefulWidget {
  final Groups group;


  GroupChat({
    Key key,

    this.group,
  });

  static Widget create(BuildContext context, {Groups groups}) {
    return Provider<Database>(
      create: (_) => DatabaseService(),
      child: GroupChatScreen(group: groups,),
    );
  }

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  Groups updatedGroup;
  Groups passingGroup;
  String currentuserid;
  SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    getCurrUser();
  }

  getCurrUser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid");
    });
  }

   Widget groupChatDetailPageAppBar() {

    return AppBar(
      elevation: 15,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: InkWell(
             onTap: () {
              print("tap");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewGroupPageAppBar(
                        group: passingGroup,
                        edit : true,
                        currentuserid : currentuserid,
                      ),
                    ),
                  );
                },
              child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(passingGroup.photoUrl),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),

                Expanded(
                child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          passingGroup.name,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        // StatusIndicator(
                        //   uid: receiverId,
                        //   screen: "chatDetailScreen",
                        // )
                        // SizedBox(
                        //       height: 5,
                        //     ),
                           
                        Text(
                          "${passingGroup.users.length} participants",
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                
                
              ],
            ),
          ),
        ),
      ),
      actions:widget.group.admin.contains(currentuserid) ? [
        IconButton(
                
                icon: Icon(
                  // Icons.video_call,
                  Icons.person_add ,
                  color: Colors.grey.shade700,
                ),
                onPressed: () async {
                  final result =await  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // builder: (context) => NewGroupPageAppBar(),
                      builder: (context) => AddAdminPage(group: passingGroup,edit: true,),
                    ),
                  );

                  if(result != null){
                    setState(() {
                      passingGroup = result;
                      // print("new length ${passingGroup.users.length}");
                    });
                  }
                },                  
              ),
        
      ]: [
        IconButton(
          icon: Icon(
            // Icons.video_call,
            Icons.add,
            color: Colors.grey.shade700,
          ),
          onPressed: () async {
            final result =await  Navigator.push(
              context,
              MaterialPageRoute(
                // builder: (context) => NewGroupPageAppBar(),
                builder: (context) => AddParticipantsPage(group: passingGroup,edit: true,),
              ),
            );

            if(result != null){
              setState(() {
                passingGroup = result;
                // print("new length ${passingGroup.users.length}");
              });
            }
          },                  
        ),
      ],
    );
  }

  // getGroup()async {
  //   final database = Provider.of<Database>(context, listen: true);
  //   updatedGroup = await database.getGroupData(widget.group.gid);
  //   // print("=======================================\t $updatedGroup");
  // }
  @override
  Widget build(BuildContext context) {
    if(passingGroup == null) passingGroup = widget.group;
    // getGroup();
    // print("curruserid $currUserId");
    return  Scaffold(
        appBar: groupChatDetailPageAppBar(

        ),
        body: GroupChatScreen(
          // receiverId: receiverId,
          // receiverAvatar: receiverAvatar,
          group: passingGroup,
        ),
      );
    
  }
}

class GroupChatScreen extends StatefulWidget {
  final Groups group;

  GroupChatScreen({
    Key key,

    this.group,
  }) : super(key: key);

  static Widget create(BuildContext context, {Groups groups}) {
    return Provider<Database>(
      create: (_) => DatabaseService(),
      child: GroupChatScreen(group: groups,),
    );
  }

  @override
  State createState() => GroupChatScreenState(

      );
}

class GroupChatScreenState extends State<GroupChatScreen> {


  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;

  File imageFile;
  String imageUrl;
  final picker = ImagePicker();

  String chatId;
  String id;
  String name;
  SharedPreferences preferences;

  String recieverFcmToken;

  var listMessage = [];

  PopupMenu menu;
  GlobalKey gifBtnKey = GlobalKey();

  @override
  void dispose() {
    // implement dispose
    super.dispose();
    _textEditingController.dispose();
    _listScrollController.dispose();
  }

  @override
  void initState() {
    // implement initState
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

    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("uid") ?? "";
    name = preferences.getString("name");
   
  }

  Future<bool> callOnFcmApiSendPushNotifications(
      String userToken, String body, String image) async {
    // print("SENDING PUSH NOTIFICATION to ${userToken}");
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
      'Authorization': "key=$FCM_SERVER_KEY" // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(postUrl,
        body: jsonEncode(data),
        // encoding: Encoding.getByName('utf-8'),
        headers: headers);
    // print("sent");
    if (response.statusCode == 200) {
      // on success do sth
      // print('test ok push CFM');
      return true;
    } else {
      print(' CFM error ${response.reasonPhrase}');
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
    // final database = Provider.of<Database>(context, listen: true);
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
    final database = Provider.of<Database>(context, listen: true);
    return Flexible(
      child: id == ""
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(kPrimaryColor)),
            )
          : StreamBuilder<List<GroupMessages>>(
              stream: database.getAllGroupMessages(widget.group.gid),
              
              builder: (context, snapshot) {
                if(snapshot.hasError){
                  print("error =========== ${snapshot.error}");
                }
                if (!snapshot.hasData) {
                  // print("nodata");
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kPrimaryColor)),
                  );
                } else {
                  listMessage = snapshot.data;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    // itemBuilder: (context, index) =>
                    //     createItem(index, listMessage[index]),
                    itemBuilder: (context, index) {
                      // print("hello in item");
                      return FutureBuilder<User>(
                        future: database.getUserData(listMessage[index].createdBy),
                        builder: (context,snapshot1){
                          if(snapshot1.hasError || snapshot1.data == null){
                            print("snapshot1 error ${snapshot1.error}");
                            return Container();
                          }else{
                            return createItem(index, listMessage[index],snapshot1.data);
                          }
                          
                          // print("snapsho1 ${snapshot1.data}");
                          
                      });
                    },
                    itemCount: listMessage.length,
                    reverse: true,
                    controller: _listScrollController,
                  );
                }
              },
            ),
    );
  }

  onDeleteMsg(GroupMessages message) {
    print("===============================  \n${message.mid}");
    var docRef = Firestore.instance
        .collection("Groups")
        .document(widget.group.gid)
        .collection("Chat")
        .document(message.timestamp);
    if (message.timestamp == listMessage[0].timestamp) {
      //check type of document if image delete from storage
      if (message.type == 1) {
        firebase_storage.FirebaseStorage.instance
            .getReferenceFromUrl(message.content)
            // .delete().then((value) => print("deleted"));
            .then((res) {
          res.delete().then((value) => print("Deleted"));
        });
      }
      // 𝘛𝘩𝘪𝘴 𝘮𝘦𝘴𝘴𝘢𝘨𝘦 𝘸𝘢𝘴 𝘥𝘦𝘭𝘦𝘵𝘦𝘥
      docRef.updateData({
        "content": "🚫 𝘛𝘩𝘪𝘴 𝘮𝘴𝘨 𝘸𝘢𝘴 𝘥𝘦𝘭𝘦𝘵𝘦𝘥",
        "type": -1,
      });
      //change content and type of document
      //change from chatlist as well on both sides
      Firestore.instance
          .collection("Groups")
          .document(widget.group.gid)
          .updateData({
        "lastMessage": "🚫 𝘛𝘩𝘪𝘴 𝘮𝘴𝘨 𝘸𝘢𝘴 𝘥𝘦𝘭𝘦𝘵𝘦𝘥",
        "lastMessageType": -1,
      });


    } else {
      if (message.type == 1) {
        firebase_storage.FirebaseStorage.instance
            .getReferenceFromUrl(message.content)
            // .delete().then((value) => print("Deleted"));
            .then((res) {
          res.delete().then((value) => print("Deleted"));
        });
      }
      docRef.updateData({
        "content": "🚫 𝘛𝘩𝘪𝘴 𝘮𝘴𝘨 𝘸𝘢𝘴 𝘥𝘦𝘭𝘦𝘵𝘦𝘥",
        "type": -1,
      });
    }
    //else
    //check type of document if image delete from storage getref from imageurl
    //change content and type of document
  }

  //clear all chat(){}

  bool isLastMsgLeft(int index) {
    if ((index > 0 && listMessage != null) &&
            listMessage[index - 1].createdBy == id ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 && listMessage != null) &&
            listMessage[index - 1].createdBy != id ||
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
        int.parse(listMessage[index].timestamp));
    DateTime prev = DateTime.fromMillisecondsSinceEpoch(
        int.parse(listMessage[index + 1].timestamp));
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
        int.parse(listMessage[index].timestamp));
    if (curr.day == today.day) {
      return true;
    } else {
      return false;
    }
  }

  bool isYesterday(int index) {
    DateTime today = DateTime.now();
    DateTime curr = DateTime.fromMillisecondsSinceEpoch(
        int.parse(listMessage[index].timestamp));
    if (curr.day == (today.day - 1)) {
      return true;
    } else {
      return false;
    }
  }

  createItem(int index, GroupMessages message,User user) {
    // final database = Provider.of<Database>(context, listen: false);
    //Logged User Messages - right side
    if (message.createdBy == id) {
      print("right");
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
                                        int.parse(message.timestamp))),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.0)),
                  )
                : Container(),

            Row(
              children: [
                message.type == -1
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
                                message.content,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Text(
                                DateFormat("hh:mm aa").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(message.timestamp))),
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
                        onPressed: () {print("========================  \t ${message.mid}");},
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
                                onDeleteMsg(message);
                              }),
                        ],
                        child: Container(
                          child: message.type == 0
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
                                          message.content,
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
                                                      message.timestamp))),
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
                              : message.type == 1
                                  ? Container(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FullPhoto(
                                                          url: message.content)));
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
                                            imageUrl: message.content,
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
                                  : message.type == 2
                                      ? Container(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullPhoto(
                                                              url: message.content)));
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
                                                imageUrl: message.content,
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
                                            "images/${message.content}.gif",
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
            message.type != 0 && message.type != -1
                ? Container(
                    child: Text(
                      DateFormat("hh:mm aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(message.timestamp))),
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
      
      // User user =  database.getUserData(message.createdBy);
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
                                        int.parse(message.timestamp))),
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
                          // imageUrl: receiverAvatar,
                          imageUrl: user.photoUrl,
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

                message.type == -1
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
                                message.content,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Text(
                                DateFormat("hh:mm aa").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(message.timestamp))),
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
                    message.type == 0
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
                                    message.content,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 10.0, top: 5.0),
                                  child: Text(
                                    DateFormat("hh:mm aa").format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(message.timestamp))),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.0,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ))

                        // Image Msg
                        : message.type == 1
                            ? Container(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullPhoto(
                                                url: message.content)));
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
                                      imageUrl: message.content,
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
                            : message.type == 2
                                ? Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FullPhoto(
                                                    url: message.content)));
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
                                          imageUrl: message.content,
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
                                      "images/${message.content}.gif",
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
            message.type != 0 && message.type != -1
                ? Container(
                    child: Text(
                      DateFormat("hh:mm aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(message.timestamp))),
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

       
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
                controller: _textEditingController,
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
                onPressed: () => onSendMessage(_textEditingController.text, 0),
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
    final database = Provider.of<Database>(context, listen: false);
    //type=0 => text Msg
    //type=1 => Image File
    //type=2 => GIF
    //type=3 => Sticker

    setState(() {
      isDisplaySticker = false;
    });

    String currTime = DateTime.now().millisecondsSinceEpoch.toString();

    if (contentMsg != "") {
      String body = (type == 0)
          ? contentMsg
          : type == 1 ? "Image" : type == 2 ? "GIF" : "Sticker";
      String image = (type == 1) ? contentMsg : "";

      for (int i = 0; i < widget.group.users.length; i++) {
        callOnFcmApiSendPushNotifications(recieverFcmToken, body, image);
        print(i);
      }
      
      _textEditingController.clear();

    
      GroupMessages message = GroupMessages(
        mid: currTime,
        createdBy: id,
        timestamp : currTime,
        content: contentMsg,
        type: type,
      );
       database.createMessage(widget.group.gid, message);
         Firestore.instance
            .document('Groups/${widget.group.gid}/')
            .updateData({"lastMessageTime": currTime,"lastMessage":contentMsg,"lastSender" : name,"lastMessageType":type});
      _listScrollController.animateTo(0.0,
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
    firebase_storage.StorageReference storageReference =
        firebase_storage.FirebaseStorage.instance.ref().child("group images").child(fileName);

    firebase_storage.StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
    firebase_storage.StorageTaskSnapshot storageTaskSnapshot =
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
