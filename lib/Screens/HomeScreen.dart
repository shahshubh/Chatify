import 'package:Chatify/Screens/AccountSettings/AccountSettingsPage.dart';
import 'package:Chatify/Screens/Chats/Chats.dart';
import 'package:Chatify/Screens/ChatDetail/ChattingPage.dart';
import 'package:Chatify/Screens/Chats/UserList.dart';
import 'package:Chatify/constants.dart';
import 'package:Chatify/enum/user_state.dart';
import 'package:Chatify/resources/user_state_methods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import 'package:Chatify/Models/user.dart';

class HomeScreen extends StatefulWidget {
  final String currentuserid;
  HomeScreen({Key key, @required this.currentuserid}) : super(key: key);
  @override
  _HomeScreenState createState() =>
      _HomeScreenState(currentuserid: currentuserid);
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  _HomeScreenState({Key key, @required this.currentuserid});

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      UserStateMethods()
          .setUserState(userId: currentuserid, userState: UserState.Online);
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid, userState: UserState.Online)
            : print("Resumed State");
        break;
      case AppLifecycleState.inactive:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid, userState: UserState.Offline)
            : print("Inactive State");
        break;
      case AppLifecycleState.paused:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid, userState: UserState.Waiting)
            : print("Paused State");
        break;
      case AppLifecycleState.detached:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid, userState: UserState.Offline)
            : print("Detached State");
        break;
    }
  }

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
      // appBar: AppBar(
      //   title: const Text('Chat App'),
      //   backgroundColor: kPrimaryColor,
      //   centerTitle: true,
      // ),
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
