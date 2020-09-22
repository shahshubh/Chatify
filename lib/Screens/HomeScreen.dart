import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/Welcome/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  final String currentuserid;
  HomeScreen({Key key, @required this.currentuserid}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
        onPressed: logoutuser,
        icon: Icon(Icons.close),
        label: Text("Sign Out"));
  }

  Future<Null> logoutuser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (route) => false);
  }
}
