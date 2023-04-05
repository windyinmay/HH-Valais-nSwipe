import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nswipe/screens/homepage.dart';
import 'package:nswipe/utils/firebase_service.dart';

import '../reusable_widgets/reusable_widget.dart';

class VerifySmsScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const VerifySmsScreen(
      {Key? key, required this.phoneNumber, required this.verificationId})
      : super(key: key);

  @override
  State<VerifySmsScreen> createState() => _VerifySmsScreenState();
}

class _VerifySmsScreenState extends State<VerifySmsScreen> {
  TextEditingController _otpTextController = TextEditingController();

  signInPhone(String otp) async {
    await FirebaseAuth.instance.currentUser
        ?.updatePhoneNumber(PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: otp))
        .onError((error, stackTrace) {
      _buildPopupDialog(context);
    });
    FirebaseService().updateHasShop();
    FirebaseAuth.instance.currentUser?.reload();
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
            Navigator.of(context).pop();
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
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF1FFFA),
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 200),
                        Text(
                          'Un code de vérification a été envoyer au numéro ${widget.phoneNumber}',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        reusableTextField("Code de vérification", null, false,
                            _otpTextController),
                        const SizedBox(height: 10),
                        firebaseUIButton(context, "Valider", () {
                          signInPhone(_otpTextController.text);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                          );
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
                                  builder: (context) => const HomePage()),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ))
          ],
        ));
  }
}