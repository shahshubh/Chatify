import 'package:ChatApp/Screens/AccountSettingsPage.dart';
import 'package:ChatApp/Screens/Chats.dart';
import 'package:ChatApp/Screens/ChattingPage.dart';
import 'package:ChatApp/Screens/UserList.dart';
import 'package:ChatApp/Widgets/ProgressWidget.dart';
import 'package:ChatApp/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ChatApp/Screens/Welcome/welcome_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ChatApp/Models/user.dart';

class HomeScreen extends StatefulWidget {
  final String currentuserid;
  HomeScreen({Key key, @required this.currentuserid}) : super(key: key);
  @override
  _HomeScreenState createState() =>
      _HomeScreenState(currentuserid: currentuserid);
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState({Key key, @required this.currentuserid});

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  final String currentuserid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: homePageHeader(),
      // body: futureSearchResults == null
      //     ? displayNosearchResultScreen()
      //     : displayUserFoundScreen(),
      body: MyStatefulWidget(),
    );
  }

  homePageHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.settings,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (contex) => Settings()));
          },
        )
      ],
      backgroundColor: Colors.lightBlue,
      title: Container(
        margin: new EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          style: TextStyle(fontSize: 18.0, color: Colors.white),
          controller: searchTextEditingController,
          decoration: InputDecoration(
              hintText: "Search here...",
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              filled: true,
              prefixIcon: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 30.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: emptyTextFormField,
              )),
          onFieldSubmitted: controlSearching,
        ),
      ),
    );
  }

  controlSearching(String userName) {
    print(userName);

    Future<QuerySnapshot> allFoundUsers = Firestore.instance
        .collection("Users")
        .where("name", isGreaterThanOrEqualTo: userName)
        .getDocuments();

    setState(() {
      futureSearchResults = allFoundUsers;
    });
  }

  emptyTextFormField() {
    searchTextEditingController.clear();
  }

  displayUserFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return oldcircularprogress();
        }
        List<UserResult> searchUserResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);

          if (currentuserid != document["uid"]) {
            searchUserResult.add(userResult);
          }
        });

        // print(searchUserResult);
        return ListView(
          children: searchUserResult,
        );
      },
    );
  }

  displayNosearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              Icons.group,
              color: Colors.lightBlueAccent,
              size: 200.0,
            ),
            Text(
              "Search Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 50.0,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => sendUserToChatPage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                      CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.name,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Joined: " +
                      DateFormat("dd MMMM, yyyy - hh:mm:aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(eachUser.createdAt))),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  sendUserToChatPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                receiverId: eachUser.uid,
                receiverAvatar: eachUser.photoUrl,
                receiverName: eachUser.name)));
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[ChatsPage(), UserList(), Settings()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text('Chats'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            title: Text('Users'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('Profile'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        onTap: _onItemTapped,
      ),
    );
  }
}
