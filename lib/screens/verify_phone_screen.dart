import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nswipe/screens/homepage.dart';
import 'package:nswipe/screens/verify_sms_screen.dart';

import '../reusable_widgets/reusable_widget.dart';
import '../validation.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({Key? key}) : super(key: key);

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  bool _submitted = false;
  String verificationId = "";

  TextEditingController _phoneNumberTextController = TextEditingController();

  String? get _errorPhoneNumber {
    return errorPhoneNumber(_phoneNumberTextController);
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    setState(() => _submitted = true);
    if (_errorPhoneNumber != null) {
      return;
    }

    ///Send the verification code
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumberTextController.text,
        verificationCompleted: (AuthCredential authCredential) {},
        verificationFailed: (FirebaseAuthException firebaseAuthException) {
          _buildPopupDialog(context);
        },
        codeSent: (String verId, int? forceCodeResent) {
          verificationId = verId;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => VerifySmsScreen(
                    phoneNumber: phoneNumber, verificationId: verificationId)),
          );
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        });
  }

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Message d'erreur"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Une erreur c'est produite, réessayer plus tard."),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: const Text('Fermer'),
        )
      ],
    );
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 200),
            const Text(
              'Entre ton numéro de téléphone pour débloquer ta boutique: ',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            const SizedBox(height: 20),
            reusableTextField(
                "Exemple: +41 79 123 12 12",
                _submitted ? _errorPhoneNumber : null,
                false,
                _phoneNumberTextController),
            firebaseUIButton(context, "Valider", () {
              verifyPhoneNumber(_phoneNumberTextController.text);
            })
          ],
        ),
      ),
    );
  }
}