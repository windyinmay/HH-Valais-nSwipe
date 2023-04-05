import 'dart:developer';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nswipe/screens/shop/addItemPage.dart';
import 'package:nswipe/screens/homepage.dart';

import 'package:nswipe/utils/firebase_service.dart';

class AddItemForm extends StatefulWidget {
  const AddItemForm({Key? key}) : super(key: key);

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _addItemFormKey = GlobalKey<FormState>();

  final FirebaseService firebaseService = FirebaseService();

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  dynamic _pickImageError;
  String? _retrieveDataError;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  String dropdownValue = "Categoriés";
  var items = [
    "Categoriés",
    "Homme",
    "Femme",
    "Enfant",
    "Pantalon",
    "Robe/jupe",
    "Pull",
    "T-shirt",
    "Tops",
    "Chaussures",
    "Accessoires",
  ];

  saveItem() async {
    String imageUrl = await firebaseService.saveImage(File(_imageFile!.path));
    String description = _descriptionController.text;
    String condition = _conditionController.text;
    double? price = double.tryParse(_priceController.text);
    String color = _colorController.text;
    String category = dropdownValue;
    if (imageUrl.isNotEmpty) {
      firebaseService.saveItemToDb(
          imageUrl, description, condition, price, color, category);
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text("Cancel"));
    Widget confirmButton = TextButton(
        onPressed: () async {
          try {
            await saveItem();
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Item saved!")));
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          } catch (err) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Could not save item, try again.")));
            Navigator.of(context).pop();
            log(err.toString());
          }
        },
        child: const Text("Confirm"));

    AlertDialog alert = AlertDialog(
      title: const Text("Confirm"),
      content: const Text("Publish item?"),
      actions: [cancelButton, confirmButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future<void> _onImageButtonPressed() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
          source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
      setState(() {
        _imageFile = pickedImage;
      });
    } catch (err) {
      setState(() {
        _pickImageError = err;
      });
    }
  }

  Widget _showImage() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }

    if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    }

    return _imageFile == null
        ? SizedBox(
            width: 250.0,
            height: 250.0,
            child: IconButton(
              icon: Icon(
                Icons.add_photo_alternate_outlined,
                size: 50.0,
                semanticLabel: 'Add image.',
              ),
              onPressed: () {
                _onImageButtonPressed();
              },
            ),
          )
        : GestureDetector(
            child: Image.file(
              File(_imageFile!.path),
              height: 250.0,
              width: 250.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              _onImageButtonPressed();
            },
          );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }

    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _addItemFormKey,
          autovalidateMode: AutovalidateMode.always,
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                const SizedBox(height: 30),
                Container(
                  child: defaultTargetPlatform == TargetPlatform.android
                      ? FutureBuilder<void>(
                          future: retrieveLostData(),
                          builder: (BuildContext context,
                              AsyncSnapshot<void> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.done:
                                return _showImage();
                              default:
                                if (snapshot.hasError) {
                                  return Text(
                                    'Pick image error: ${snapshot.error}}',
                                    textAlign: TextAlign.center,
                                  );
                                }
                                return const Text('');
                            }
                          })
                      : _showImage(),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField(
                  value: dropdownValue,
                  items: items.map((String items) {
                    return DropdownMenuItem(value: items, child: Text(items));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  validator: ((value) {
                    if (value == null || value == "Catégories") {
                      return 'Select a category';
                    }
                    return null;
                  }),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Description (taille/marque):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextFormField(
                  controller: _descriptionController,
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a description like size or brand.';
                    }
                    return null;
                  }),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Défauts/Etat:', //Condition
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextFormField(
                  controller: _conditionController,
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter condition for example "like new" or "slightly used".';
                    }
                    return null;
                  }),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Prix:', //Price
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: ((value) {
                    if (value == null ||
                        value.isEmpty ||
                        double.tryParse(value) == null) {
                      return 'Enter price.';
                    }
                    return null;
                  }),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Couleur:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextFormField(
                  controller: _colorController,
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter item color.';
                    }
                    return null;
                  }),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Color(0xFF785964)),
                    onPressed: (() {
                      if (_addItemFormKey.currentState!.validate()) {
                        showAlertDialog(context);
                      }
                    }),
                    child: const Text("Publier")),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
