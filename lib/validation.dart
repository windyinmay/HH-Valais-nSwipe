import 'package:flutter/material.dart';

///File that contain all validations fields

///Validation for basic text (not empty)
String? errorText(TextEditingController controller) {
  final text = controller.value.text;

  if (text.isEmpty) {
    return 'Ne peut pas être vide';
  }

  return null;
}

///Validation for email address (not empty, .@...)
String? errorEmail(TextEditingController controller) {
  final text = controller.value.text;

  if (text.isEmpty) {
    return 'Ne peut pas être vide';
  }

  String pattern =
      r"^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$";
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(text)) {
    return 'Entrer une adresse e-mail valide';
  }

  return null;
}

///Validation for swiss telephone number (not empty, swiss number)
String? errorPhoneNumber(TextEditingController controller) {
  final text = controller.value.text;

  if (text.isEmpty) {
    return 'Ne peut pas être vide';
  }

  String pattern = r"(\+41)\s(\d{2})\s(\d{3})\s(\d{2})\s(\d{2})";
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(text)) {
    return 'Entrer un numéro de téléphone valide';
  }

  return null;
}

///Validation for password (not empty, 6 lengths, uppercase, lowercase, digits)
String? errorPassword(TextEditingController controller) {
  final text = controller.value.text;
  if (text.isEmpty) {
    return 'Ne peut pas être vide';
  }

  //Min characters password
  int minLength = 6;
  bool hasMinLength = text.length >= minLength;
  if (!hasMinLength) {
    return "Doit contenir au moins " + minLength.toString() + " caractères";
  }

  //At least one uppercase
  bool hasUppercase = text.contains(new RegExp(r'[A-Z]'));
  if (!hasUppercase) {
    return "Need to contain one uppercase character !";
  }

  //At leat one lowercase
  bool hasLowercase = text.contains(new RegExp(r'[a-z]'));
  if (!hasLowercase) {
    return "Doit avoir au moins une majuscule !";
  }

  //Contains some disgits
  bool hasDigits = text.contains(new RegExp(r'[0-9]'));
  if (!hasDigits) {
    return "Doit avoir au moins un nombre !";
  }
  return null;
}

///Validation for confirmation password (same password, not empty)
String? errorPasswordConfirmation(
    TextEditingController passwordConfirmationController,
    TextEditingController passwordController) {
  if (passwordConfirmationController.text.isEmpty) {
    return 'Ne peut pas être vide';
  }
  if (passwordConfirmationController.value.text !=
      passwordController.value.text) {
    return "Les deux mots de passe ne sont pas identique !";
  }
  return null;
}
