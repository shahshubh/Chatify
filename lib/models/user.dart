import 'package:flutter/foundation.dart';

class User {
  final String chattingWith;
  final String createdAt;
  final String email;
  final String fcmToken;
  final String lastSeen;
  final String photoUrl;
  final int state;
  final String uid;
  // final String token;
  final String name;

  User(
      {@required 
      this.chattingWith,
      this.createdAt,
      this.email,
      this.fcmToken,
      this.lastSeen,
      this.name,
      this.photoUrl,
      this.state,
      this.uid,
      });

  Map<String, dynamic> toMap() {
    return {
      
      'chattingWith' : chattingWith,
      'createdAt'  : createdAt,
      'email': email,
      'fcmToken' : fcmToken,
      'lastSeen' : lastSeen,
      'name'     : name,
      'photoUrl' : photoUrl,
      'state'  : state,
      'uid': uid,
   
    };
  }

  factory User.fromMap(Map<dynamic, dynamic> data) {
    // print(data);
    return User(

      chattingWith: data['chattingWith'],
      createdAt: data['createdAt'],
      email: data["email"],
      fcmToken: data['fcmToken'],
      lastSeen: data['lastSeen'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      state: data['state'],
      uid: data["uid"],

    );
  }
}
