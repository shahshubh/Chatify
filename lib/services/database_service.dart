import 'package:Chatify/models/group.dart';
import 'package:Chatify/models/groupMessages.dart';
import 'package:Chatify/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' as au;


abstract class Database {

  Future<User> getUserData(String uid);
  Future<Groups> getGroupData(String gid);
  Stream<List<Groups>> getAllGroups();
  Stream<List<GroupMessages>> getAllGroupMessages(String gid);
  Future<void> createMessage(String gid, GroupMessages message);
  Future<void> editGroupDetails(Groups group);

}

class DatabaseService implements Database {

  Future<User> getUserData(String uid) async {
    String path = "Users/$uid";
    final refernce = Firestore.instance.document(path);
    final data =
        await refernce.get().then((value) => User.fromMap(value.data));
    // print(data);
    return data;
  }

  Future<Groups> getGroupData(String gid) async {
    String path = "Groups/$gid";
    final refernce = Firestore.instance.document(path);
    final data =
        await refernce.get().then((value) => Groups.fromMap(value.data));
    // print("group========================================================\n $data");
    return data;
  }


    Stream<List<Groups>> getAllGroups() {
    String path = "Groups/";
    final reference = Firestore.instance.collection(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) =>
        snapshot.documents.map((doc) => Groups.fromMap(doc.data)).toList());
  }

  Stream<List<GroupMessages>> getAllGroupMessages(String gid) {
    String path = "Groups/$gid/Chat/";
    final reference = Firestore.instance.collection(path).orderBy("timestamp", descending: true);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) =>
        snapshot.documents.map((doc) => GroupMessages.fromMap(doc.data)).toList());
  }

  Future<void> createMessage(String gid, GroupMessages message) async {
    // try {
      final path = "Groups/$gid/Chat/${message.mid}";
      final reference = Firestore.instance.document(path);
      await reference.setData(message.toMap());
    // } on FirebaseException catch (e) {
    //   print(e.code);
    //   throw FirebaseException(
    //       code: e.code,
    //       message: "Some error occurred while creating group try again later");
    // }
  }

  Future<void> editGroupDetails(Groups group) async {
    // try {
      String path = "Groups/${group.gid}";
      await Firestore.instance.document(path).updateData(group.toMap());
    // } on FirebaseException catch (e) {
    //   print(e.code);
    //   throw FirebaseException(
    //       code: e.code,
    //       message: "Some error occurred while updating group try again later");
    // }
  }
}