import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nswipe/reusable_widgets/reusable_widget.dart';

import '../../validation.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool _submitted = false;

  TextEditingController _emailTextController = TextEditingController();

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
                  firebaseUIButton(context, "Réinitialiser le mot de passe", () {
                    setState(() => _submitted = true);
                    if (_errorEmail != null) {
                      return;
                    }
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(
                            email: _emailTextController.text)
                        .then((value) => Navigator.of(context).pop());
                  })
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}
