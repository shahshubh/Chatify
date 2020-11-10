import 'dart:math';

import 'package:Chatify/constants.dart';
import 'package:Chatify/models/call.dart';
import 'package:Chatify/models/log.dart';
import 'package:Chatify/screens/CallScreens/call_screen.dart';
import 'package:Chatify/resources/call_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {String currUserAvatar,
      String currUserName,
      String currUserId,
      String receiverAvatar,
      String receiverName,
      String receiverId,
      context}) async {
    Call call = Call(
      callerId: currUserId,
      callerName: currUserName,
      callerPic: currUserAvatar,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverPic: receiverAvatar,
      channelId: Random().nextInt(1000).toString(),
    );

    Log log = Log(
        callerName: currUserName,
        callerPic: currUserAvatar,
        callStatus: CALL_STATUS_DIALLED,
        receiverName: receiverName,
        receiverPic: receiverAvatar,
        timestamp: DateTime.now().toString());

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Firestore.instance
          .collection("Users")
          .document(currUserId)
          .collection("callLogs")
          .document(log.timestamp)
          .setData({
        "callerName": log.callerName,
        "callerPic": log.callerPic,
        "callStatus": log.callStatus,
        "receiverName": log.receiverName,
        "receiverPic": log.receiverPic,
        "timestamp": log.timestamp
      });

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              call: call,
            ),
          ));
    }
  }
}
