import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String photoUrl;
  final String createdAt;

  User({
    this.uid,
    this.name,
    this.photoUrl,
    this.createdAt,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc.documentID,
      photoUrl: doc['photoUrl'],
      name: doc['name'],
      createdAt: doc['createdAt'],
    );
  }
}
