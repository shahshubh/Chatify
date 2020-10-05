import 'dart:async';
import 'package:Chatify/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'package:Chatify/Screens/Welcome/welcome_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:video_player/video_player.dart';
import 'package:Chatify/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  SharedPreferences preferences;
  AnimationController animationController;
  Animation<double> animation;
  var _visible = true;

  final FirebaseMessaging _messaging = FirebaseMessaging();
  String fcmToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 3));
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    precachePicture(
        ExactAssetPicture(
            SvgPicture.svgStringDecoder, 'assets/icons/signup.svg'),
        null);
    precachePicture(
        ExactAssetPicture(SvgPicture.svgStringDecoder, 'assets/icons/chat.svg'),
        null);
    precachePicture(
        ExactAssetPicture(
            SvgPicture.svgStringDecoder, 'assets/icons/login.svg'),
        null);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    _messaging.getToken().then((value) {
      fcmToken = value;
    });
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 6, milliseconds: 500);
    return new Timer(_duration, navigateuser);
  }

  void navigateuser() async {
    preferences = await SharedPreferences.getInstance();

    await FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        Firestore.instance
            .collection("Users")
            .document(preferences.getString("uid"))
            .updateData({"fcmToken": fcmToken});

        Route route = MaterialPageRoute(
            builder: (c) =>
                HomeScreen(currentuserid: preferences.getString("uid")));
        Navigator.pushReplacement(context, route);
      } else {
        Route route = MaterialPageRoute(builder: (c) => WelcomeScreen());
        Navigator.pushReplacement(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/images/image2.png',
                width: animation.value * 250,
                height: animation.value * 250,
              ),
            ],
          ),
          Positioned(
            bottom: 20.0,
            child: Container(
              color: Colors.purple[200],
              child: TextLiquidFill(
                text: 'Chatify',
                waveColor: Colors.purple,
                boxBackgroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courgette',
                ),
                boxHeight: 150.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
