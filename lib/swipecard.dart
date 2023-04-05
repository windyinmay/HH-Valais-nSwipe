import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipable/flutter_swipable.dart';
import 'package:nswipe/utils/firebase_service.dart';
import 'utils/globals.dart' as globals;

class SwipeCard extends StatefulWidget {
  final String image;

  const SwipeCard({Key? key, required this.image}) : super(key: key);

  @override
  _SwipeCardState createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  final FirebaseService _service = FirebaseService();
  bool isShown = false;
  List list = [];

  @override
  void initState() {
    super.initState();
    updateData();
  }

  void updateData() {
    _service.getImageInfo(globals.images[0]).then((value) => setState(() {
          list = value;
        }));
  }

  void nextItem() {
    if (globals.images.isEmpty) return;
    globals.images.removeAt(0);
  }

  Widget imageInfo() {
    updateData();
    if (isShown) {
      return Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(list[0] + '\n' + list[1] + '\n' + list[2],
                  style: const TextStyle(fontSize: 16)),
            ],
          ));
    } else {
      return Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Double-cliquez pour plus d\'informations !',
              style: TextStyle(fontSize: 18)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return globals.images.isEmpty
        ? const Center(
            child: Text('Plus d\'articles...'),
          )
        : SizedBox.expand(
            child: Swipable(
              child: GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    isShown = !isShown;
                  });
                },
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: NetworkImage(widget.image),
                          fit: BoxFit.cover,
                          alignment: const Alignment(-0.3, 0)),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: imageInfo(),
                  )
                ]),
              ),
              onSwipeLeft: (_) {
                setState(() {
                  nextItem();
                  print(globals.images);
                  isShown = false;
                  updateData();
                });
              },
              onSwipeRight: (_) {
                setState(() {
                  _service.addToFavorites(widget.image);
                  _service.getAllFavorites().then((value) => {
                        setState(() {
                          globals.favorites = value;
                        })
                      });
                  nextItem();
                  isShown = false;
                  updateData();
                });
              },
            ),
          );
  }
}
