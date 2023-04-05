import 'package:flutter/material.dart';
import 'package:nswipe/screens/shop/addItemForm.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFFA),
      body: const Center(child: Text("Click button below to add item.")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF785964),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddItemForm())),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
