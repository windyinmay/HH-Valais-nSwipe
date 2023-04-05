import 'dart:developer';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:nswipe/utils/globals.dart' as globals;
import 'package:nswipe/auth_service.dart';

class FirebaseService {
  FirebaseService();

  final AuthService auth = AuthService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<List<dynamic>> getAllImages() async {
    var favorites = await getAllFavorites();

    var users = await getAllUsers();
    var data = [];
    for (var user in users) {
      await _userCollection
          .doc(user)
          .collection('sales')
          .get()
          .then((QuerySnapshot snapshot) {
        for (var doc in snapshot.docs) {
          if (doc.id == 'clothing') {
            List list = doc['data'] as List;
            if (list.isNotEmpty) {
              for (var item in list) {
                if (favorites.isNotEmpty) {
                  for (var fav in favorites) {
                    if (item['id'] != fav) {
                      data.add(item['imageUrl']);
                    }
                  }
                } else {
                  data.add(item['imageUrl']);
                }
              }
            }
          }
        }
      });
    }
    return data;
  }

  Future<List<dynamic>> getImageDecPriceById(List ids) async {
    var users = await getAllUsers();
    var data = [];
    for (var user in users) {
      await _userCollection
          .doc(user)
          .collection('sales')
          .get()
          .then((QuerySnapshot snapshot) {
        for (var doc in snapshot.docs) {
          if (doc.id == 'clothing') {
            List list = doc['data'] as List;
            for (var item in list) {
              for (var id in ids) {
                if (item['id'] == id && item['imageUrl'] != '') {
                  data.add({
                    'id': item['id'],
                    'image': item['imageUrl'],
                    'description': item['description'],
                    'price': item['price']
                  });
                }
              }
            }
          }
        }
      });
    }
    return data;
  }

  Future<List<dynamic>> getAllFavorites() async {
    var data = [];
    await _userCollection
        .doc(userId)
        .collection('favorites')
        .get()
        .then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        if (doc.id == 'clothing') {
          List list = doc['data'] as List;
          for (var item in list) {
            if (item != '') {
              data.add(item);
            }
          }
        }
      }
    });

    return data;
  }

  Future<String> getItemId(String image) async {
    var users = await getAllUsers();
    var itemId = '';
    for (var user in users) {
      await _userCollection
          .doc(user)
          .collection('sales')
          .get()
          .then((QuerySnapshot snapshot) {
        for (var doc in snapshot.docs) {
          if (doc.id == 'clothing') {
            List list = doc['data'] as List;
            for (var item in list) {
              if (item['imageUrl'] == image && item['imageUrl'] != '') {
                itemId = item['id'];
              }
            }
          }
        }
      });
    }
    return itemId;
  }

  Future addToFavorites(String image) async {
    var itemId = await getItemId(image);

    var list = [itemId];

    await _userCollection
        .doc(userId)
        .collection('favorites')
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.size == 0) {
        await _userCollection
            .doc(userId)
            .collection('favorites')
            .doc('clothing')
            .set({'data': FieldValue.arrayUnion(list)});
      } else {
        await _userCollection
            .doc(userId)
            .collection('favorites')
            .doc('clothing')
            .update({'data': FieldValue.arrayUnion(list)});
      }
    });
  }

  Future deleteFromFavorites(String id) async {
    globals.favorites.remove(id);
    await _userCollection
        .doc(userId)
        .collection('favorites')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs[0].reference.delete();
    });

    if (globals.favorites.isNotEmpty) {
      await _userCollection
          .doc(userId)
          .collection('favorites')
          .doc('clothing')
          .set({'data': FieldValue.arrayUnion(globals.favorites)});
    }
  }

  Future<List<dynamic>> getImageInfo(String image) async {
    var users = await getAllUsers();
    var data = [];
    for (var user in users) {
      await _userCollection
          .doc(user)
          .collection('sales')
          .get()
          .then((QuerySnapshot snapshot) {
        for (var doc in snapshot.docs) {
          if (doc.id == 'clothing') {
            List list = doc['data'] as List;
            for (var item in list) {
              if (item['imageUrl'] == image && item['imageUrl'] != '') {
                data.add(item['description']);
                data.add(item['condition']);
                data.add(item['price'].toString());
              }
            }
          }
        }
      });
    }
    return data;
  }

  Future<List<dynamic>> getItemSellerInfo(String image) async {
    var users = await getAllUsers();
    var seller = [];
    for (var user in users) {
      await _userCollection
          .doc(user)
          .collection('sales')
          .get()
          .then((QuerySnapshot snapshot) async {
        for (var doc in snapshot.docs) {
          if (doc.id == 'clothing') {
            List list = doc['data'] as List;
            for (var item in list) {
              if (item['imageUrl'] == image && item['imageUrl'] != '') {
                await _userCollection.get().then((QuerySnapshot snapshot) {
                  for (var doc in snapshot.docs) {
                    if (user == doc.id) {
                      seller.add(doc['FirstName']);
                      seller.add(doc['PhoneNumber']);
                      seller.add(doc['email']);
                    }
                  }
                });
              }
            }
          }
        }
      });
    }
    return seller;
  }

  Future<String> getBuyersName() async {
    var name = '';
    await _userCollection.get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        if (userId == doc.id) {
          name = doc['FirstName'] + ' ' + doc['LastName'];
        }
      }
    });
    return name;
  }

  Future<List<dynamic>> getAllUsers() async {
    var data = [];
    await _userCollection.get().then((QuerySnapshot snapshot) => {
          for (var doc in snapshot.docs) {data.add(doc.id)}
        });

    return data;
  }

  Future<void> saveItemToDb(String imageUrl, String description,
      String condition, double? price, String color, String category) async {
    if (userId.isEmpty) {
      log("User ID not found.");
    } else {
      try {
        await _userCollection
            .doc(userId)
            .collection('favorites')
            .get()
            .then((QuerySnapshot snapshot) async {
          if (snapshot.size == 0) {
            await _userCollection
                .doc(userId)
                .collection('sales')
                .doc('clothing')
                .set({
              "data": FieldValue.arrayUnion([
                {
                  "id": 'randomid1',
                  "imageUrl": imageUrl,
                  "description": description,
                  "condition": condition,
                  "price": price,
                  "color": color,
                  "category": category
                }
              ])
            });
          }
          else {
            await _userCollection
                .doc(userId)
                .collection('sales')
                .doc('clothing')
                .update({
              "data": FieldValue.arrayUnion([
                {
                  "id": 'randomid1',
                  "imageUrl": imageUrl,
                  "description": description,
                  "condition": condition,
                  "price": price,
                  "color": color,
                  "category": category
                }
              ])
            });
          }
        });
      } catch (err) {
        log(err.toString());
      }
    }
  }

  Future saveImage(File _imageFile) async {
    try {
      final String filename = basename(_imageFile.path);
      await firebase_storage.FirebaseStorage.instance
          .ref('/images')
          .child('/$userId/$filename')
          .putFile(_imageFile);

      String downloadUrl = await firebase_storage.FirebaseStorage.instance
          .ref('images/$userId/$filename')
          .getDownloadURL();
      return downloadUrl;
    } catch (err) {
      log(err.toString());
    }
  }

  Future<bool> hasShop() async {
    if (await _userCollection.doc(userId).get() != null) {
      DocumentSnapshot snapshot = await _userCollection.doc(userId).get();
      if (snapshot.exists) {
        return snapshot.get("hasShop");
      }
    }
    return false;
  }

  Future updateHasShop() async {
    await _userCollection.doc(userId).update({"hasShop": true, "email": FirebaseAuth.instance.currentUser!.email});
  }
}
