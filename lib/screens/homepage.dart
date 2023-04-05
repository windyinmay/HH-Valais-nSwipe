import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nswipe/auth_service.dart';
import 'package:nswipe/screens/catalog/catalogpage.dart';
import 'package:nswipe/screens/favorites/favoritespage.dart';
import 'package:nswipe/screens/swipe/swipepage.dart';
import 'package:nswipe/screens/verify_shop_screen.dart';
import 'package:nswipe/utils/globals.dart' as globals;
import 'package:nswipe/utils/firebase_service.dart';

import 'login/signin_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final FirebaseService _service = FirebaseService();
  final user = FirebaseAuth.instance.currentUser!;
  final AuthService _auth = AuthService();

  final screens = [
    SwipePage(),
    //CatalogPage(),
    FavoritesPage(),
    VerifyShopScreen(),
  ];

  void updateUsers() {
    _service.getAllUsers().then((value) => {
          setState(() {
            globals.users = value.toList();
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    updateUsers();
    final items = <Widget>[
      Icon(
        Icons.pan_tool,
        size: 30,
        color: Colors.white,
      ),
      //Icon(Icons.dashboard, size: 30, color: Colors.white),
      Icon(Icons.shopping_cart, size: 30, color: Colors.white),
      Icon(Icons.store, size: 30, color: Colors.white),
    ];

    return SafeArea(
        top: false,
        child: ClipRect(
          child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text("nSwipe"),
                backgroundColor: const Color(0xFFF1FFFA),
                elevation: 0,
                foregroundColor: Colors.black,
                actions: <Widget>[
                  FlatButton.icon(
                    icon: Icon(Icons.person),
                    label: Text('Log out'),
                    onPressed: () {
                      AuthService().signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()));
                    },
                  )
                ],
              ),
              body: IndexedStack(
                index: index,
                children: screens,
              ),
              bottomNavigationBar: CurvedNavigationBar(
                items: items,
                height: 60,
                animationCurve: Curves.easeInOut,
                animationDuration: const Duration(milliseconds: 400),
                index: index,
                color: Color(0xFF785964),
                backgroundColor: const Color(0xFFF1FFFA),
                onTap: (index) => setState(() {
                  this.index = index;
                }),
              )),
        ));
  }
}
