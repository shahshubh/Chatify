import 'package:Chatify/constants.dart';
import 'package:Chatify/screens/CallLogs/log_list_container.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String currentuserid;
  SharedPreferences preferences;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrUserId();
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Call Logs',
          style: TextStyle(
              fontFamily: 'Courgette', letterSpacing: 1.25, fontSize: 24),
        ),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: LogListContainer(
        currentuserid: currentuserid,
      ),
    );
  }
}
