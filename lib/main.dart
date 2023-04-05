import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nswipe/screens/login/signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'nSwipe',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SignInScreen());
  }
}
