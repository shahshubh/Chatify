import 'package:ChatApp/components/chat_for_chats_screen.dart';
import 'package:ChatApp/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  // List allUsers = [];
  // List allUsersWithDetails = [];
  String currentuserid;
  SharedPreferences preferences;
  // bool isLoading = false;

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
  //   isLoading = true;
  //   await getCurrUserId();
  //   QuerySnapshot querySnapshot = await Firestore.instance
  //       .collection("Users")
  //       .document(currentuserid)
  //       .collection("chatList")
  //       .orderBy("timestamp", descending: true)
  //       .getDocuments();

  //   querySnapshot.documents.forEach((element) async {
  //     await _getUsersDetails(element.data["id"]);
  //     allUsers.add(element.data);
  //   });
  //   setState(() {});
  //   if (allUsers.length != 0) {
  //     isLoading = false;
  //   } else {
  //     Timer(const Duration(seconds: 1), () {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     });
  //   }
  // }

  // _getUsersDetails(String id) async {
  //   DocumentSnapshot documentSnapshot =
  //       await Firestore.instance.collection("Users").document(id).get();

  //   allUsersWithDetails.add(documentSnapshot.data);
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // SafeArea(
            //   child: Padding(
            //     padding: EdgeInsets.only(left: 16, right: 16, top: 10),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: <Widget>[
            //         Text(
            //           "Chats",
            //           style:
            //               TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            //         ),
            //         Container(
            //           padding:
            //               EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
            //           height: 30,
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(30),
            //             color: Colors.pink[50],
            //           ),
            //           child: Row(
            //             children: <Widget>[
            //               Icon(
            //                 Icons.add,
            //                 color: Colors.pink,
            //                 size: 20,
            //               ),
            //               SizedBox(
            //                 width: 2,
            //               ),
            //               Text(
            //                 "New",
            //                 style: TextStyle(
            //                     fontSize: 14, fontWeight: FontWeight.bold),
            //               ),
            //             ],
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            //   child: TextField(
            //     decoration: InputDecoration(
            //       hintText: "Search...",
            //       hintStyle: TextStyle(color: Colors.grey.shade400),
            //       prefixIcon: Icon(
            //         Icons.search,
            //         color: Colors.grey.shade400,
            //         size: 20,
            //       ),
            //       filled: true,
            //       fillColor: Colors.grey.shade100,
            //       contentPadding: EdgeInsets.all(8),
            //       enabledBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(30),
            //           borderSide: BorderSide(color: Colors.grey.shade100)),
            //     ),
            //   ),
            // ),
            StreamBuilder(
              stream: Firestore.instance
                  .collection("Users")
                  .document(currentuserid)
                  .collection("chatList")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
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
                } else if (snapshot.data.documents.length == 0) {
                  return Container(
                    child: Column(
                      children: [
                        Text(
                          "No recent chats found",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Start searching to chat",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 16),
                    itemCount: snapshot.data.documents.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ChatChatsScreen(
                        data: snapshot.data.documents[index],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
