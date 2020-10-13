import 'package:Chatify/models/call.dart';
import 'package:Chatify/screens/CallScreens/pickup/pickup_screen.dart';
import 'package:Chatify/resources/call_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final String uid;

  final CallMethods callMethods = CallMethods();

  PickupLayout({
    @required this.scaffold,
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return uid != null
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data != null) {
                Call call = Call.fromMap(snapshot.data.data);

                if (!call.hasDialled) {
                  return PickupScreen(
                    call: call,
                  );
                }
                return scaffold;
              }

              return scaffold;
            })
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
