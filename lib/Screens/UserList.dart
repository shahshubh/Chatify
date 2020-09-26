import 'package:ChatApp/Models/user.dart';
import 'package:ChatApp/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ChatApp/components/chat.dart';
import 'package:ChatApp/models/chat_users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  // List allUsers = [];
  var allUsersList;
  String currentuserid;
  SharedPreferences preferences;

  @override
  initState() {
    super.initState();
    getCurrUserId();
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid");
    });
  }

  // _getUsers() async {
  //   await getCurrUserId();
  //   QuerySnapshot querySnapshot =
  //       await Firestore.instance.collection("Users").getDocuments();

  //   querySnapshot.documents.forEach((element) {
  //     if (element.data["uid"] != currentuserid) {
  //       allUsers.add(element.data);
  //     }
  //   });

  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: StreamBuilder(
          stream: Firestore.instance.collection("Users").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                    kPrimaryColor,
                  )),
                ),
                height: MediaQuery.of(context).copyWith().size.height -
                    MediaQuery.of(context).copyWith().size.height / 5,
                width: MediaQuery.of(context).copyWith().size.width,
              );
            } else {
              snapshot.data.documents
                  .removeWhere((i) => i["uid"] == currentuserid);
              allUsersList = snapshot.data.documents;
              return ListView.builder(
                padding: EdgeInsets.only(top: 16),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ChatUsersList(
                      name: snapshot.data.documents[index]["name"],
                      secondaryText: "Secondary Text",
                      image: snapshot.data.documents[index]["photoUrl"],
                      time: snapshot.data.documents[index]["createdAt"],
                      isMessageRead: true,
                      userId: snapshot.data.documents[index]["uid"],
                      screen: "UserListScreen");
                },
              );
            }
          },
        ),
      ),
    );
  }
}
