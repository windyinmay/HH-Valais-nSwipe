import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nswipe/screens/login/signin_screen.dart';

import '../../reusable_widgets/reusable_widget.dart';
import '../homepage.dart';

///Verify email screen
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  ///InitState function to send email if not verified when arrive at this screen.
  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 5),
        (_) => checkEmailVerified(),
      );
    }
  }

  ///Dispose function to close timer when leaving the screen.
  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  ///Function to check if a user is verified.
  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  ///Function to send a verification email to new user or not verified user.
  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
      });
    } catch (e) {
      print('Probleme sur l\'envoie du mail');
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const HomePage()
      : Scaffold(
          backgroundColor: const Color(0xFFF1FFFA),
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFF1FFFA),
            elevation: 0,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
          ),
          body: Column(
            children: [
              Column(
                children: const [
                  Text(
                    "nSwipe",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Un mail de confirmation vous a été envoyé',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    firebaseUIButton(context, "Renvoyer l'email", () {
                      sendVerificationEmail();
                    }),
                    TextButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(20),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ));
}
