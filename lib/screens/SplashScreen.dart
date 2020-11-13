import 'package:Chatify/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'HomeScreen.dart';
import 'package:Chatify/screens/Welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  SharedPreferences preferences;
  // AnimationController animationController;
  // Animation<double> animation;
  // var _visible = true;

  final FirebaseMessaging _messaging = FirebaseMessaging();
  String fcmToken;
  bool isAlreadyLoggedIn = false;
  String currentuserid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // animationController = new AnimationController(
    //     vsync: this, duration: new Duration(seconds: 3));
    // animation =
    //     new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    navigateuser();

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

    // animation.addListener(() => this.setState(() {}));
    // animationController.forward();

    // setState(() {
    //   _visible = !_visible;
    // });
    // startTime();
  }

  // startTime() async {
  //   var _duration = new Duration(seconds: 6, milliseconds: 500);
  //   return new Timer(_duration, navigateuser);
  // }

  void navigateuser() async {
    preferences = await SharedPreferences.getInstance();
    currentuserid = preferences.getString("uid");

    fcmToken = await _messaging.getToken();

    await FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        Firestore.instance
            .collection("Users")
            .document(preferences.getString("uid"))
            .updateData({"fcmToken": fcmToken});

        setState(() {
          isAlreadyLoggedIn = true;
        });

        // Route route = MaterialPageRoute(
        //     builder: (c) =>
        //         HomeScreen(currentuserid: preferences.getString("uid")));
        // Navigator.pushReplacement(context, route);
      } else {
        setState(() {
          isAlreadyLoggedIn = false;
        });
        // Route route = MaterialPageRoute(builder: (c) => WelcomeScreen());
        // Navigator.pushReplacement(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      home: isAlreadyLoggedIn
          ? HomeScreen(currentuserid: currentuserid)
          : WelcomeScreen(),
      duration: 5500,
      imageSrc: "assets/images/icon_new.png",
      text: "Chatify",
      textType: TextType.ColorizeAnimationText,
      textStyle: TextStyle(fontSize: 40.0, fontFamily: 'Courgette'),
      colors: [
        kPrimaryColor,
        kPrimaryLightColor,
        kPrimaryColor,
      ],
      backgroundColor: Colors.white,
    );

    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   body: Stack(
    //     alignment: Alignment.center,
    //     fit: StackFit.expand,
    //     children: <Widget>[
    //       new Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           new Image.asset(
    //             'assets/images/image2.png',
    //             width: animation.value * 250,
    //             height: animation.value * 250,
    //           ),
    //         ],
    //       ),
    //       Positioned(
    //         bottom: 20.0,
    //         child: Container(
    //           color: Colors.purple[200],
    //           child: TextLiquidFill(
    //             text: 'Chatify',
    //             waveColor: kPrimaryColor,
    //             boxBackgroundColor: Colors.white,
    //             textStyle: TextStyle(
    //               fontSize: 60.0,
    //               fontWeight: FontWeight.bold,
    //               fontFamily: 'Courgette',
    //             ),
    //             boxHeight: 150.0,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
