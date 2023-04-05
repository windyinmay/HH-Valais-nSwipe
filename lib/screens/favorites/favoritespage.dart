import 'dart:developer';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nswipe/utils/firebase_service.dart';
import 'package:nswipe/utils/globals.dart' as globals;
import 'package:http/http.dart' as http;

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  FirebaseService _service = FirebaseService();
  final currentUser = FirebaseAuth.instance.currentUser;

  var data = [];
  var totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    updateData();
  }

  double calculatePrice() {
    double total = 0.0;
    if (data.isEmpty) {
      return 0.0;
    }

    for (var element in data) {
      total += element['price'];
    }

    return total;
  }

  void updateData() {
    _service.getAllFavorites().then((value) => {
          setState(() {
            globals.favorites = value;
          })
        });

    _service.getImageDecPriceById(globals.favorites).then((value) => {
          setState(() {
            data = value;
          })
        });

    totalPrice = calculatePrice();
  }

  Widget favoriteItem(dynamic info) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(info['image']),
          ),
          Text(info['description']),
          Text('${info['price']} CHF'),
          SizedBox(
              width: 25.0,
              height: 25.0,
              child: RawMaterialButton(
                onPressed: () async {
                  _service.deleteFromFavorites(info['id']);
                },
                fillColor: Color(0xFF785964),
                child: Icon(
                  Icons.delete,
                  size: 15.0,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(5.0),
                shape: CircleBorder(),
              ))
        ]));
  }

  Future sendEmail({
    required String userEmail,
    required String adminEmail,
    required String subject,
    required String orderNumber,
    required String description,
    required String totalQuantity,
    required String totalPrice,
  }) async {
    const serviceId = 'service_ydko0dk';
    const templateId = 'template_6rvrvyd';
    const userId = '6akU55Lfm5_TsViMR';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_email': userEmail,
            'admin_email': adminEmail,
            'user_subject': subject,
            'order_number': orderNumber,
            'item_description': description,
            'total_quantity': totalQuantity,
            'total_price': totalPrice,
          }
        }),
      );
      log(response.body);
    } catch (err) {
      log(err.toString());
    }
  }

  Future sendEmailToBuyer({
    required String userEmail,
    required String adminEmail,
    required String subject,
    required String orderNumber,
    required String description,
    required String totalQuantity,
    required String totalPrice,
  }) async {
    const serviceId = 'service_ydko0dk';
    const templateId = 'template_6rvrvyd';
    const userId = '6akU55Lfm5_TsViMR';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_email': userEmail,
            'admin_email': adminEmail,
            'user_subject': subject,
            'order_number': orderNumber,
            'item_description': description,
            'total_quantity': totalQuantity,
            'total_price': totalPrice,
          }
        }),
      );
      log(response.body);
    } catch (err) {
      log(err.toString());
    }
  }

  Future composeOrderConfirmation() async {
    if (currentUser == null) {
      log('Utilisateur actuel non trouvé');
    } else {
      String? userEmail = currentUser!.email;
      String replyEmail = 'noreply@nswipe.com';
      String subject = 'Confirmation Order';
      String orderNumber = '#12345';

      List descriptions = [];
      for (var item in data) {
        var seller = await _service.getItemSellerInfo(item['image']);

        descriptions.add(
            'Item: ${item['description']} x 1, Price: ${item['price']}, Seller: ${seller[0]}, Seller contact: ${seller[1]}');
      }

      String totalQuantity = data.length.toString();
      String total = totalPrice.toString();

      await sendEmail(
        userEmail: userEmail.toString(),
        adminEmail: replyEmail,
        subject: subject,
        orderNumber: orderNumber,
        description: descriptions.toString(),
        totalQuantity: totalQuantity,
        totalPrice: total,
      );
    }
  }

  Future composePurchaseConfirmation() async {
    if (currentUser == null) {
      log('Current user not found');
    } else {
      String? userEmail = currentUser!.email;
      String replyEmail = 'noreply@nswipe.com';
      String subject = 'Confirmation Order';
      String orderNumber = '#12345';
      var name = await _service.getBuyersName();

      List descriptions = [];
      for (var item in data) {
        var seller = await _service.getItemSellerInfo(item['image']);

        descriptions.add(
            'Item: ${item['description']} x 1, Price: ${item['price']}, Buyer\'s email: ${userEmail.toString()}, Buyer\'s name: ${name}');

        String totalQuantity = data.length.toString();
        String total = totalPrice.toString();

        await sendEmailToBuyer(
          userEmail: seller[2],
          adminEmail: replyEmail,
          subject: subject,
          orderNumber: orderNumber,
          description: descriptions.toString(),
          totalQuantity: totalQuantity,
          totalPrice: total,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    updateData();
    return globals.favorites.isEmpty
        ? Container(
            color: const Color(0xFFF1FFFA),
            child: Center(
              child: Text('Aucun article dans les favoris...'),
            ))
        : Scaffold(
            backgroundColor: const Color(0xFFF1FFFA),
            body: Column(
              children: [
                Column(
                    children: data.map((info) => favoriteItem(info)).toList()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 75),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Total'), Text('${totalPrice} CHF')],
                  ),
                ),
                Container(
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await composeOrderConfirmation();
                        await composePurchaseConfirmation();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Confirmation de la commande envoyée à votre adresse mail!")));
                      } catch (err) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Impossible d'envoyer l'e-mail cette fois-ci, réessayez plus tard.")));
                        log(err.toString());
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF785964))),
                    child: Text(
                      'Buy',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
