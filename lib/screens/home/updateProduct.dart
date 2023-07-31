import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopping_app/shared/constants.dart';
import 'dart:io';

class UpdateProduct extends StatefulWidget {
  final String title;
  final String desc;
  final double price;
  final String category;
  final String image;
  UpdateProduct(
      {required this.title,
      required this.desc,
      required this.price,
      required this.category,
      required this.image});
  @override
  _UpdateProductState createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  int id = 0;
  String title = '';
  String desc = '';
  double price = 0.0;
  String category = '';
  String? image;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String getUserID() {
    return _firebaseAuth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    // Create a CollectionReference called products that references the firestore collection

    CollectionReference products =
        FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(
        title: Text("Update Products"),
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
                  initialValue: widget.title,
                  onChanged: (val) => setState(() => title = val),
                ),
                SizedBox(height: 20.0),
                SizedBox(height: 0.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: "Price"),
                  initialValue: widget.price.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => price = double.parse(val)),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(height: 0.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: "Category"),
                  initialValue: widget.category,
                  onChanged: (val) => setState(() => category = val),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(height: 0.0),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      textInputDecoration.copyWith(hintText: "Description"),
                  initialValue: widget.desc,
                  onChanged: (val) => setState(() => desc = val),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Image.network(
                    image != null && image!.isNotEmpty? image! : widget.image,
                    width:100.0,
                    height: 100.0,
                ),
                SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    XFile? _image = await singleImagePicker();
                    if(_image!=null && _image!.path.isNotEmpty){
                      image = await uploadImage(_image);
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
                    products
                        .doc(widget.title)
                        .delete()
                        .then((value) => print("Product Deleted"))
                        .catchError((error) => print("Failed to delete product"));
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(getUserID())
                        .collection('products')
                        .doc(widget.title)
                        .delete()
                        .then((value) => print("Product Deleted"))
                        .catchError(
                            (error) => print("Failed to delete product: $error"));
                    Navigator.pop(context);
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(getUserID())
                        .collection('products')
                        .doc(title != '' ? title : widget.title)
                        .set({
                          'title': title != '' ? title : widget.title,
                          'price': price != 0.0 ? price : widget.price,
                          "category": category != '' ? category : widget.category,
                          "desc": desc != '' ? desc : widget.desc,
                          "image": image != ''
                              ? image
                              : 'https://www.yorkshirecareequipment.com/wp-content/uploads/2018/09/no-image-available.jpg?x87029',
                          'fav': [
                            '',
                          ]
                        })
                        .then((value) => print("User Added"))
                        .catchError(
                            (error) => print("Failed to add user: $error"));
                    products
                        .doc(title != '' ? title : widget.title)
                        .set({
                          'title': title != '' ? title : widget.title,
                          'price': price != 0.0 ? price : widget.price,
                          "category": category != '' ? category : widget.category,
                          "desc": desc != '' ? desc : widget.desc,
                          "image": image != ''
                              ? image
                              : 'https://www.yorkshirecareequipment.com/wp-content/uploads/2018/09/no-image-available.jpg?x87029',
                          'fav': [
                            '',
                          ]
                        })
                        .then((value) => print("User Added"))
                        .catchError(
                            (error) => print("Failed to add user: $error"));
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Update",
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