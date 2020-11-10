import 'dart:async';
import 'dart:io';
import 'package:Chatify/widgets/ProgressWidget.dart';
import 'package:Chatify/constants.dart';
import 'package:Chatify/resources/user_state_methods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Settings",
          style: TextStyle(
              fontFamily: 'Courgette', letterSpacing: 1.25, fontSize: 24),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.signOutAlt),
            onPressed: () => UserStateMethods().logoutuser(context),
          )
        ],
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  SharedPreferences preferences;
  TextEditingController nameTextEditingController;
  TextEditingController emailTextEditingController;

  String id = "";
  String name = "";
  String email = "";
  String photoUrl = "";
  File imageFileAvatar;
  final picker = ImagePicker();
  bool isLoading = false;
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  bool _status = true;
  bool isInitialLoading = false;
  final FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
  }

  Future<String> readDataFromLocal() async {
    isInitialLoading = true;
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("uid");
    name = preferences.getString("name");
    photoUrl = preferences.getString("photo");
    email = preferences.getString("email");

    nameTextEditingController = TextEditingController(text: name);
    emailTextEditingController = TextEditingController(text: email);
    isInitialLoading = false;
    setState(() {});
    // return Future.delayed(Duration(seconds: 2), () => "Hello");
    // return photoUrl;
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imageFileAvatar = File(pickedFile.path);
        isLoading = true;
      }
    });

    if (pickedFile != null) {
      // upload image to firebase storage
      uploadImageToFirestoreAndStorage();
    }
  }

  Future uploadImageToFirestoreAndStorage() async {
    String mFileName = id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask storageUploadTask =
        storageReference.putFile(imageFileAvatar);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photoUrl = newImageDownloadUrl;
          Firestore.instance.collection("Users").document(id).updateData(
              {"photoUrl": photoUrl, "name": name}).then((data) async {
            await preferences.setString("photo", photoUrl);

            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Updated Successfully.");
          });
        }, onError: (errorMsg) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Error occured in getting Download Url !");
        });
      }
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

  void updateData() {
    nameFocusNode.unfocus();
    emailFocusNode.unfocus();
    setState(() {
      isLoading = false;
    });

    Firestore.instance
        .collection("Users")
        .document(id)
        .updateData({"name": name}).then((data) async {
      await preferences.setString("photo", photoUrl);
      await preferences.setString("name", name);

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Updated Successfully.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return isInitialLoading
        ? oldcircularprogress()
        : Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    //Profile Image - Avatar
                    Container(
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            (imageFileAvatar == null)
                                // ? (photoUrl != "")
                                ? Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Material(
                                            // display already existing image
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors
                                                              .lightBlueAccent),
                                                ),
                                                width: 200.0,
                                                height: 200.0,
                                                padding: EdgeInsets.all(20.0),
                                              ),
                                              imageUrl: photoUrl,
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(125.0)),
                                            clipBehavior: Clip.hardEdge),
                                      ],
                                    ),
                                  )
                                // : Icon(
                                //     Icons.account_circle,
                                //     size: 90.0,
                                //     color: Colors.grey,
                                //   )
                                : Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Material(
                                            // display new updated image
                                            child: Image.file(
                                              imageFileAvatar,
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(125.0)),
                                            clipBehavior: Clip.hardEdge),
                                      ],
                                    ),
                                  ),
                            GestureDetector(
                              onTap: getImage,
                              child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 150.0, right: 120.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 25.0,
                                        child: new Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                      width: double.infinity,
                      margin: EdgeInsets.all(20.0),
                    ),

                    Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(1.0),
                        child: isLoading ? oldcircularprogress() : Container(),
                      ),
                    ]),

                    new Container(
                      color: Color(0xFFFFFFFF),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 25.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          'Personal Information',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    new Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        _status
                                            ? _getEditIcon()
                                            : new Container(),
                                      ],
                                    )
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          'Name',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new TextField(
                                        decoration: const InputDecoration(
                                          hintText: "Enter Your Name",
                                        ),
                                        controller: nameTextEditingController,
                                        enabled: !_status,
                                        autofocus: !_status,
                                        onChanged: (value) {
                                          name = value;
                                        },
                                        focusNode: nameFocusNode,
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          'Email ID',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new TextField(
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                            hintText: "Enter Email ID"),
                                        enabled: !_status,
                                        controller: emailTextEditingController,
                                        focusNode: emailFocusNode,
                                      ),
                                    ),
                                  ],
                                )),
                            !_status ? _getActionButtons() : new Container(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
              )
            ],
          );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Update"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                  updateData();
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                  // logoutuser();
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}
