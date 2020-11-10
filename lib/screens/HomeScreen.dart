import 'package:Chatify/screens/AccountSettings/AccountSettingsPage.dart';
import 'package:Chatify/screens/CallLogs/log_screen.dart';
import 'package:Chatify/screens/Chats/Chats.dart';
import 'package:Chatify/screens/Chats/UserList.dart';
import 'package:Chatify/constants.dart';
import 'package:Chatify/enum/user_state.dart';
import 'package:Chatify/resources/user_state_methods.dart';
import 'package:Chatify/screens/CallScreens/pickup/pickup_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
    return PickupLayout(
      uid: currentuserid,
      scaffold: Scaffold(
        body: MyStatefulWidget(),
      ),
    );
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
  List<Widget> _widgetOptions = <Widget>[
    ChatsPage(),
    UserList(),
    LogScreen(),
    Settings(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 65.0,
        backgroundColor: Colors.white,
        color: kPrimaryLightColor,
        buttonBackgroundColor: kPrimaryLightColor,
        items: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(
              Icons.chat,
              color: _selectedIndex == 0 ? kPrimaryColor : Colors.black,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(
              Icons.supervised_user_circle,
              color: _selectedIndex == 1 ? kPrimaryColor : Colors.black,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(
              Icons.call,
              color: _selectedIndex == 2 ? kPrimaryColor : Colors.black,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(
              Icons.person_outline,
              color: _selectedIndex == 3 ? kPrimaryColor : Colors.black,
            ),
          ),
        ],
        // currentIndex: _selectedIndex,
        // selectedItemColor: kPrimaryColor,
        // selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        // unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        onTap: _onItemTapped,
      ),
    );
  }
}
