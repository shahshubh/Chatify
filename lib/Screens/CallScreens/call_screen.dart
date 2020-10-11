import 'dart:async';

import 'package:Chatify/Models/call.dart';
import 'package:Chatify/resources/call_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallScreen extends StatefulWidget {
  final Call call;

  CallScreen({
    @required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();

  SharedPreferences preferences;
  StreamSubscription callStreamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addPostFrameCallback();
  }

  addPostFrameCallback() async {
    preferences = await SharedPreferences.getInstance();
    callStreamSubscription = callMethods
        .callStream(uid: preferences.getString("uid"))
        .listen((DocumentSnapshot ds) {
      switch (ds.data) {
        case null:
          // snapshot is null i.e. the call is hanged and document is deleted
          Navigator.pop(context);
          break;

        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    callStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Call has been made"),
            MaterialButton(
              color: Colors.red,
              child: Icon(Icons.call_end, color: Colors.white),
              onPressed: () {
                callMethods.endCall(call: widget.call);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
