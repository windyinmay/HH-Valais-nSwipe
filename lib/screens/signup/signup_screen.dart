import 'package:flutter/material.dart';
import 'package:nswipe/reusable_widgets/reusable_widget.dart';
import 'package:nswipe/screens/login/signin_screen.dart';
import 'package:nswipe/screens/signup/verify_email_screen.dart';

import '../../auth_service.dart';
import '../../validation.dart';

/// Sign up screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _submitted = false;

  ///All fields controller
  TextEditingController _firstNameTextController = TextEditingController();
  TextEditingController _lastNameTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _passwordConfirmationController =
      TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _birthdateTextController = TextEditingController();

  ///Errors messages
  String? get _errorFirstName {
    return errorText(_firstNameTextController);
  }

  String? get _errorLastName {
    return errorText(_lastNameTextController);
  }

  String? get _errorEmail {
    return errorEmail(_emailTextController);
  }

  String? get _errorPassword {
    return errorPassword(_passwordTextController);
  }

  String? get _errorPasswordConfirmation {
    return errorPasswordConfirmation(
        _passwordConfirmationController, _passwordTextController);
  }

  ///Function to create a new account by clicking in the Sign Up button
  signUp() async {
    setState(() => _submitted = true);
    if (_errorFirstName != null ||
        _errorLastName != null ||
        _errorEmail != null ||
        _errorPassword != null ||
        _errorPasswordConfirmation != null) {
      return;
    }

    AuthService auth = AuthService();

    await auth
        .register(
            _firstNameTextController.text,
            _lastNameTextController.text,
            _birthdateTextController.text,
            _emailTextController.text.trim(),
            _passwordTextController.text.trim())
        .then((value) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => VerifyEmailScreen()));
    }).onError((error, stackTrace) {
      _buildPopupDialog(context);
    });
  }

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Message d'erreur"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Une erreur c'est produite, réessayez plus tard."),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const SignInScreen()),
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
                    reusableTextField(
                        "Prénom",
                        _submitted ? _errorFirstName : null,
                        false,
                        _firstNameTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Nom", _submitted ? _errorLastName : null,
                        false, _lastNameTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextFieldBirthDate("Date de naissance", null,
                        context, _birthdateTextController),
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
                        "Mot de passe",
                        _submitted ? _errorPassword : null,
                        true,
                        _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField(
                        "Confirmer le mot de passe",
                        _submitted ? _errorPasswordConfirmation : null,
                        true,
                        _passwordConfirmationController),
                    const SizedBox(
                      height: 10,
                    ),
                    firebaseUIButton(context, "S'inscrire", () {
                      signUp();
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
