import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Models/user.dart';
import 'package:flutter_auth/Screens/Login/components/background.dart';
import 'package:flutter_auth/Screens/Signup/signup_screen.dart';
import 'package:flutter_auth/components/already_have_an_account_acheck.dart';
import 'package:flutter_auth/components/rounded_button.dart';
import 'package:flutter_auth/components/rounded_inputname_field.dart';
import 'package:flutter_auth/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  SharedPreferences preferences;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  static const kPrimaryColor = Color(0xFF6F35A5);
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

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
              Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.35,
              ),
              SizedBox(height: size.height * 0.03),
              TextFormField(
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
                    Icons.person,
                    color: kPrimaryColor,
                  ),
                  hintText: "Your Email",
                  border: InputBorder.none,
                ),
              ),
              TextFormField(
                controller: passwordEditingController,
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
                  suffixIcon: Icon(
                    Icons.visibility,
                    color: kPrimaryColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
              RoundedButton(
                text: "LOGIN",
                press: () {
                  loginUser();
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SignUpScreen();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    FirebaseUser firebaseUser;

    await _auth
        .signInWithEmailAndPassword(
            email: emailEditingController.text.trim(),
            password: passwordEditingController.text.trim())
        .then((auth) {
      firebaseUser = auth.user;
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });

    if (firebaseUser != null) {
      Firestore.instance
          .collection("Users")
          .document(firebaseUser.uid)
          .get()
          .then((datasnapshot) async {
        await preferences.setString("uid", datasnapshot.data[firebaseUser.uid]);
        await preferences.setString(
            "name", datasnapshot.data[firebaseUser.displayName]);
        await preferences.setString(
            "photo", datasnapshot.data[firebaseUser.photoUrl]);
      });
    } else {
      Fluttertoast.showToast(msg: "Sign in Failed");
    }
  }
}
