import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nswipe/swipecard.dart';
import 'package:nswipe/utils/firebase_service.dart';
import 'package:nswipe/utils/globals.dart' as globals;

class SwipePage extends StatefulWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final FirebaseService _service = FirebaseService();

  Future<void> updateImages() async {
    _service.getAllImages().then((value) => {
          setState(() {
            globals.images = value;
          })
        });
  }

  @override
  void initState() {
    super.initState();
    updateImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        color: const Color(0xFFF1FFFA),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Stack(
            children: globals.images
                .map((image) => SwipeCard(image: image))
                .toList()
                .reversed
                .toList()),
      ),
    ));
  }
}
