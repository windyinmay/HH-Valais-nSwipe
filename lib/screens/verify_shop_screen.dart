import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nswipe/reusable_widgets/reusable_widget.dart';
import 'package:nswipe/screens/shop/addItemPage.dart';
import 'package:nswipe/screens/verify_phone_screen.dart';
import 'package:nswipe/utils/firebase_service.dart';

class VerifyShopScreen extends StatefulWidget {
  const VerifyShopScreen({Key? key}) : super(key: key);

  @override
  State<VerifyShopScreen> createState() => _VerifyShopScreenState();
}

class _VerifyShopScreenState extends State<VerifyShopScreen> {
  bool hasShop = false;
  int counter = 0;
  Timer? timer;

  Future getHasShop() async {
    hasShop = await FirebaseService().hasShop();
    counter++;
    setState(() {
      counter;
      hasShop;
    });
    if (hasShop || counter > 2) timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    getHasShop();
    if (!hasShop) {
      timer = Timer.periodic(
        Duration(seconds: 1),
            (_) => getHasShop(),
      );
    }
    print(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (hasShop) {
      return AddItemPage();
    } else {
      if (counter < 2) {
        return Scaffold(
            backgroundColor: const Color(0xFFF1FFFA),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Chargement",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                )
              ],
            ));
      } else {
        return Scaffold(
            backgroundColor: const Color(0xFFF1FFFA),
            extendBodyBehindAppBar: false,
            body: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  firebaseUIButton(context, "Crée ta boutique nSwipe", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VerifyPhoneScreen()),
                    );
                  })
                ],
              ),
            ));
      }
    }
  }
}