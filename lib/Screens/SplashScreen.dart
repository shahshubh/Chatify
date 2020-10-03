import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'package:ChatApp/Screens/Welcome/welcome_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  SharedPreferences preferences;
  AnimationController animationController;
  Animation<double> animation;
  // VideoPlayerController playerController;
  // VoidCallback listener;
  var _visible = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 3));
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    // listener = () {
    //   setState(() {});
    // };
    // initializeVideo();
    // playerController.play();
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 6);
    return new Timer(_duration, navigateuser);
  }

  void navigateuser() async {
    // playerController.setVolume(0.0);
    // playerController.removeListener(listener);
    preferences = await SharedPreferences.getInstance();

    await FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
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

  // void initializeVideo() {
  //   playerController = VideoPlayerController.asset('assets/videos/intro1.mp4')
  //     ..addListener(listener)
  //     ..setVolume(1.0)
  //     ..initialize()
  //     ..play();
  // }

  // @override
  // void deactivate() {
  //   if (playerController != null) {
  //     playerController.setVolume(0.0);
  //     playerController.removeListener(listener);
  //   }
  //   super.deactivate();
  // }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   if (playerController != null) playerController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              TextLiquidFill(
                text: 'Chatify',
                waveColor: Colors.purple,
                boxBackgroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                ),
                boxHeight: 300.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
  //       Scaffold(
  //           body: Stack(fit: StackFit.expand, children: <Widget>[
  //     new AspectRatio(
  //         aspectRatio: 9 / 16,
  //         child: Container(
  //           child: (playerController != null
  //               ? VideoPlayer(
  //                   playerController,
  //                 )
  //               : Container()),
  //         )),
  //   ]));
  // }
}
