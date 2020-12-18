import 'package:Chatify/screens/ChatDetail/ChattingPage.dart';
import 'package:Chatify/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Chatify/components/chat_for_users_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  // List allUsers = [];
  var allUsersList;
  String currentuserid;
  String currentusername;
  String currentuserphoto;
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
      currentusername = preferences.getString("name");
      currentuserphoto = preferences.getString("photo");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Users',
          style: TextStyle(
              fontFamily: 'Courgette', letterSpacing: 1.25, fontSize: 24),
        ),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: DataSearch(
                      allUsersList: allUsersList,
                      currentuserid: currentuserid,
                      currentusername: currentusername,
                      currentuserphoto: currentuserphoto));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
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
                        image: snapshot.data.documents[index]["photoUrl"],
                        time: snapshot.data.documents[index]["createdAt"],
                        email: snapshot.data.documents[index]["email"],
                        isMessageRead: true,
                        userId: snapshot.data.documents[index]["uid"],
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

class DataSearch extends SearchDelegate {
  DataSearch(
      {this.allUsersList,
      this.currentuserid,
      this.currentusername,
      this.currentuserphoto});
  var allUsersList;
  String currentuserid;
  String currentusername;
  String currentuserphoto;
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
                    receiverName: suggestionList[index]["name"],
                    currUserId: currentuserid,
                    currUserName: currentusername,
                    currUserAvatar: currentuserphoto,
                  );
                }));
              },
              leading: Icon(Icons.person),
              title: RichText(
                text: TextSpan(
                    text: suggestionList[index]["name"]
                        .toLowerCase()
                        .substring(0, query.length),
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                    children: [
                      TextSpan(
                          text: suggestionList[index]["name"]
                              .toLowerCase()
                              .substring(query.length),
                          style: TextStyle(color: Colors.grey, fontSize: 16))
                    ]),
              ),
            ),
        itemCount: suggestionList.length);
    throw UnimplementedError();
  }
}
