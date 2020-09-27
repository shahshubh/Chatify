import 'package:ChatApp/Utils/utils.dart';
import 'package:ChatApp/enum/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserStateMethods {
  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);
    Firestore.instance.collection("Users").document(userId).updateData({
      "state": stateNum,
      "lastSeen": DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      Firestore.instance.collection("Users").document(uid).snapshots();
}
