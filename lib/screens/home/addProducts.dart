import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopping_app/shared/constants.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  int id = 0;
  String title = '';
  String desc = '';
  double price = 0.0;
  String category = '';
  String image = '';


  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String getUserID() {
    return _firebaseAuth.currentUser!.uid;
  }

  String? singleImage;

  @override
  Widget build(BuildContext context) {
    // Create a CollectionReference called products that references the firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');


    return Scaffold(
      appBar: AppBar(
        title: Text("Add Products"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 0.0,
                  ),
                  SizedBox(height: 0.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: "Title"),
                    onChanged: (val) => setState(() => title = val),
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(height: 0.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: "Price"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => price = double.parse(val)),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: "Category"),
                    onChanged: (val) => setState(() => category = val),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration:
                        textInputDecoration.copyWith(hintText: "Description"),
                    onChanged: (val) => setState(() => desc = val),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  singleImage!=null && singleImage!.isNotEmpty?
                  Image.network(
                    singleImage!,
                    height:100.0,
                    width:100.0,
                  )
                  : Image.asset(
                      "assets/noimage.jpg",
                      width:100.0,
                      height:100.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        XFile? _image = await singleImagePicker();
                        if(_image!=null && _image!.path.isNotEmpty){
                          singleImage = await uploadImage(_image);
                          setState((){});
                        }
                      },
                      child: Text("Upload an Image"),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.pink[400]),
                    ),
                    onPressed: () {
                      users
                          .doc(getUserID())
                          .collection('products')
                          .doc(title)
                          .set({
                            'id': id,
                            'title': title,
                            'price': price,
                            'category': category,
                            'desc': desc,
                            'image': singleImage != null
                                ? singleImage
                                : 'https://www.yorkshirecareequipment.com/wp-content/uploads/2018/09/no-image-available.jpg?x87029',
                            'fav': [
                              '',
                            ],
                            'del': [
                              '',
                            ]
                          })
                          .then((value) => print("Product Added"))
                          .catchError(
                              (error) => print("Failed to add product: $error"));
                      products
                          .doc(title)
                          .set({
                            'id': id,
                            'title': title,
                            'price': price,
                            'category': category,
                            'desc': desc,
                            'image': singleImage != null
                                ? singleImage
                                : 'https://www.yorkshirecareequipment.com/wp-content/uploads/2018/09/no-image-available.jpg?x87029',
                            'fav': [
                              '',
                            ],
                            'del': [
                              '',
                            ]
                          })
                          .then((value) => print("Product Added"))
                          .catchError(
                              (error) => print("Failed to add product: $error"));
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Add",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

Future<XFile?> singleImagePicker() async {
  return await ImagePicker().pickImage(source: ImageSource.gallery);
}

Future<String> uploadImage(XFile image) async {
  Reference db = FirebaseStorage.instance.ref("imagesFolder/${getImageName(image)}");
  await db.putFile(File(image.path));
  return await db.getDownloadURL();
}

String getImageName(XFile image){
  return image.path.split("/").last;
}