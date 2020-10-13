import 'package:Chatify/screens/Welcome/welcome_screen.dart';
import 'package:Chatify/utils/utils.dart';
import 'package:Chatify/enum/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStateMethods {
  SharedPreferences preferences;

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);
    Firestore.instance.collection("Users").document(userId).updateData({
      "state": stateNum,
      "lastSeen": DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      Firestore.instance.collection("Users").document(uid).snapshots();

  Future<Null> logoutuser(BuildContext context) async {
    preferences = await SharedPreferences.getInstance();
    setUserState(
        userId: preferences.getString("uid"), userState: UserState.Offline);
    await FirebaseAuth.instance.signOut();
    await preferences.clear();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (route) => false);
  }
}
