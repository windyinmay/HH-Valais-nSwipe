import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nswipe/auth_service.dart';
import 'package:nswipe/reusable_widgets/reusable_widget.dart';
import 'package:nswipe/screens/homepage.dart';
import 'package:nswipe/screens/login/reset_password.dart';
import 'package:nswipe/screens/signup/signup_screen.dart';
import 'package:nswipe/screens/signup/verify_email_screen.dart';

import '../../validation.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _submitted = false;

  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  String? get _errorEmail {
    return errorEmail(_emailTextController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFFA),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField(
                        "Adresse email",
                        _submitted ? _errorEmail : null,
                        false,
                        _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField(
                        "Mot de passe", null, true, _passwordTextController),
                    const SizedBox(
                      height: 5,
                    ),
                    forgetPassword(context),
                    firebaseUIButton(context, "Connexion", () {
                      setState(() => _submitted = true);
                      if (_errorEmail != null) {
                        return HomePage();
                      } else {
                        SignInScreen();
                      }
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerifyEmailScreen()));
                      }).onError((error, stackTrace) {
                        print("Error ${error.toString()}");
                      });
                    }),
                    signUpOption(context),
                    const SizedBox(
                      height: 10,
                    ),
                    _signWithGoogle(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row signUpOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Pas encore de compte ?",
            style: TextStyle(color: Colors.black)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Inscris-toi!",
            style: TextStyle(
                color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget _signWithGoogle(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (await AuthService().signInWithGoogle()) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/google.png",
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 10),
          const Text(
            "Se connecter avec Google",
            style: TextStyle(color: Colors.black),
          )
        ],
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white70;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Mot de passe oublié ?",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
}
