import 'package:Chatify/widgets/Progresswidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Chatify/screens/HomeScreen.dart';
import 'package:Chatify/screens/Login/login_screen.dart';
import 'package:Chatify/screens/Signup/components/background.dart';
import 'package:Chatify/components/already_have_an_account_acheck.dart';
import 'package:Chatify/components/rounded_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/text_field_container.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final String defaultPhotoUrl =
      "https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg";
  static const kPrimaryColor = Color(0xFF6F35A5);
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final FirebaseMessaging _messaging = FirebaseMessaging();
  String fcmToken;
  TextEditingController nameEditingController = new TextEditingController();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  SharedPreferences preferences;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedin = false;
  bool isloading = false;
  bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;

    _messaging.getToken().then((value) {
      fcmToken = value;
    });
  }

  void _registeruser() async {
    this.setState(() {
      isloading = true;
    });
    preferences = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser;

    await _auth
        .createUserWithEmailAndPassword(
            email: emailEditingController.text.trim(),
            password: passwordEditingController.text.trim())
        .then((auth) {
      firebaseUser = auth.user;
    }).catchError((err) {
      this.setState(() {
        isloading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(err.message)));
    });

    if (firebaseUser != null) {
      final QuerySnapshot result = await Firestore.instance
          .collection("Users")
          .where("uid", isEqualTo: firebaseUser.uid)
          .getDocuments();

      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        Firestore.instance
            .collection("Users")
            .document(firebaseUser.uid)
            .setData({
          "uid": firebaseUser.uid,
          "email": firebaseUser.email,
          "name": nameEditingController.text,
          "photoUrl": defaultPhotoUrl,
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "state": 1,
          "lastSeen": DateTime.now().millisecondsSinceEpoch.toString(),
          "fcmToken": fcmToken
        });
        FirebaseUser currentuser = firebaseUser;
        await preferences.setString("uid", currentuser.uid);
        await preferences.setString("name", nameEditingController.text);
        await preferences.setString("photo", defaultPhotoUrl);
        await preferences.setString("email", currentuser.email);
      } else {
        // FirebaseUser currentuser = firebaseUser;
        await preferences.setString("uid", documents[0]["uid"]);
        await preferences.setString("name", documents[0]["name"]);
        await preferences.setString("photo", documents[0]["photoUrl"]);
        await preferences.setString("email", documents[0]["email"]);
      }

      this.setState(() {
        isloading = false;
      });
      Navigator.pop(context);
      Route route = MaterialPageRoute(
          builder: (c) => HomeScreen(
                currentuserid: firebaseUser.uid,
              ));
      Navigator.pushReplacement(context, route);
    } else {
      this.setState(() {
        isloading = false;
      });
      Fluttertoast.showToast(msg: "Sign up Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Text(
                //   "SIGNUP",
                //   style: TextStyle(fontWeight: FontWeight.bold),
                // ),
                SizedBox(height: size.height * 0.03),
                SvgPicture.asset(
                  "assets/icons/signup.svg",
                  height: size.height * 0.35,
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: nameEditingController,
                    validator: (val) {
                      return val.isEmpty || val.length < 3
                          ? "Enter Username 3+ characters"
                          : null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: kPrimaryColor,
                      ),
                      hintText: "Your Name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: emailEditingController,
                    validator: (emailValue) {
                      if (emailValue.isEmpty) {
                        return 'This field is mandatory';
                      }

                      String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                          "\\@" +
                          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                          "(" +
                          "\\." +
                          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                          ")+";
                      RegExp regExp = new RegExp(p);

                      if (regExp.hasMatch(emailValue)) {
                        // So, the email is valid
                        return null;
                      }

                      return 'This is not a valid email';
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: kPrimaryColor,
                      ),
                      hintText: "Your Email",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: passwordEditingController,
                    obscureText: !_passwordVisible,
                    validator: (pwValue) {
                      if (pwValue.isEmpty) {
                        return 'This field is mandatory';
                      }
                      if (pwValue.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      hintText: "Password",
                      icon: Icon(
                        Icons.lock,
                        color: kPrimaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: kPrimaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                RoundedButton(
                  child: isloading
                      ? circularprogress()
                      : Text(
                          "SIGN UP",
                          style: TextStyle(color: Colors.white),
                        ),
                  press: () {
                    if (_formkey.currentState.validate()) {
                      _registeruser();
                    }
                  },
                ),
                SizedBox(height: size.height * 0.03),
                AlreadyHaveAnAccountCheck(
                  login: false,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen();
                        },
                      ),
                    );
                  },
                ),
              ]),
        ),
      ),
    );
  }
}
