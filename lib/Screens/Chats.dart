import 'package:ChatApp/components/chat_for_chats_screen.dart';
import 'package:ChatApp/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChattingPage.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  // List allUsers = [];
  var allUsersWithDetails = [];
  String currentuserid;
  SharedPreferences preferences;
  // bool isLoading = false;

  @override
  initState() {
    super.initState();
    _getUsersDetails();
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

  _getUsersDetails() async {
    await getCurrUserId();
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("Users").getDocuments();

    setState(() {
      allUsersWithDetails = querySnapshot.documents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatify'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: DataSearch(allUsersList: allUsersWithDetails));
            },
          )
        ],
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

// Search Bar

class DataSearch extends SearchDelegate {
  DataSearch({this.allUsersList});
  var allUsersList;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
    // Actions for AppBar
    throw UnimplementedError();
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading Icon on left of appBar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
    throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on selection

    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show when someone searches for something
    var userList = [];
    allUsersList.forEach((e) {
      userList.add(e);
    });
    var suggestionList = userList;

    if (query.isNotEmpty) {
      suggestionList = [];
      userList.forEach((element) {
        if (element["name"].toLowerCase().startsWith(query.toLowerCase())) {
          suggestionList.add(element);
        }
      });
    }

    // suggestionList = query.isEmpty
    //     ? suggestionList
    //     : suggestionList
    //         .where((element) => element.startsWith(query.toLowerCase()))
    //         .toList();

    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              onTap: () {
                close(context, null);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Chat(
                      receiverId: suggestionList[index]["uid"],
                      receiverAvatar: suggestionList[index]["photoUrl"],
                      receiverName: suggestionList[index]["name"]);
                }));
              },
              leading: Icon(Icons.person),
              title: RichText(
                text: TextSpan(
                    text: suggestionList[index]["name"]
                        .toLowerCase()
                        .substring(0, query.length),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: suggestionList[index]["name"]
                              .toLowerCase()
                              .substring(query.length),
                          style: TextStyle(color: Colors.grey))
                    ]),
              ),
            ),
        itemCount: suggestionList.length);
    throw UnimplementedError();
  }
}
