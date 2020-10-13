import 'dart:math';

import 'package:Chatify/models/call.dart';
import 'package:Chatify/screens/CallScreens/call_screen.dart';
import 'package:Chatify/resources/call_methods.dart';
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

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
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
