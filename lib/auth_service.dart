import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nswipe/screens/login/signin_screen.dart';

///Authentication - Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  ///Create account if the user is not in Firebase / authentication by email and password
  Future<User?> register(String firstName, String lastName, String birthdate,
      String email, String password) async {
    User? user;

    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    user = userCredential.user;

    if (user != null) {
      createUser(user.uid, firstName, lastName, birthdate);
    }

    return user;
  }

  ///Add user information in Firestore
  Future<void> createUser(String userId, String firstName, String lastName,
      String birthdate) async {
    await users.doc(userId).set({
      "FirstName": firstName,
      "LastName": lastName,
      "Birthdate": birthdate,
      "hasShop": false
    });    
  }

  Future<bool> signInWithGoogle() async {
    try {
      User? user;
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        final idToken = googleSignInAuthentication.idToken;

        Map<String, dynamic>? idMap = parseJwt(idToken!);
        final String firstName = idMap!["given_name"];
        final String lastName = idMap["family_name"];

        UserCredential userCredential =
            await _auth.signInWithCredential(authCredential);
        user = userCredential.user;

        if (user != null) {
          createUser(user.uid, firstName, lastName, "");
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic>? parseJwt(String token) {
    if (token == null) return null;
    final List<String> parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    final String payload = parts[1];
    final String normalized = base64Url.normalize(payload);
    final String resp = utf8.decode(base64Url.decode(normalized));

    final payloadMap = json.decode(resp);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }
    return payloadMap;
  }

  //sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
