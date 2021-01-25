import 'package:Chatify/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:Chatify/constants.dart';
import 'package:provider/provider.dart';
import 'Screens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await firebase_core.Firebase.initializeApp();
  runApp(
    Provider<Database>(
      create: (_) => DatabaseService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatify',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
    );
  }
}
