import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IndividualDisplay extends StatelessWidget {
  final String title;
  final String desc;
  final double price;
  final String category;
  final String image;
  IndividualDisplay(
      {this.title = '',
      this.desc = '',
      this.price = 0.0,
      this.category = '',
      this.image = ''});
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String getUserID() {
    return _firebaseAuth.currentUser!.uid;
  }
  final CollectionReference users =
  FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height:60.0,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(-2.0, -2.0),
              blurRadius: 5.0,
              spreadRadius: 2.0,
            ),
            BoxShadow(
              color: Colors.white,
              offset: const Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ),
          ],

        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              child:  Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width/2-1.0,
                decoration: BoxDecoration(
                  color: Colors.orange,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(50.0,20.0,50.0,20.0),
                  child: Text(
                    "Add to Cart",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              onTap: () async {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(getUserID())
                    .collection('cart')
                    .doc(title)
                    .get()
                    .then((DocumentSnapshot
                documentSnapshot) {
                  if (documentSnapshot.exists) {
                    users
                        .doc(getUserID())
                        .collection('cart')
                        .doc(title)
                        .delete()
                        .then((value) =>
                        print("Deleted Product"))
                        .catchError((error) => print(
                        "Error deleting product"));
                  } else {
                    print("Not");
                    users
                        .doc(getUserID())
                        .collection('cart')
                        .doc(title)
                        .set({
                      'title': title,
                      'price': price,
                      'category': category,
                      'desc': desc,
                      'image': image,
                    })
                        .then((value) =>
                        print("Product Added"))
                        .catchError((error) => print(
                        "Failed to add product: $error"));
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "Added to Cart",
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.fromLTRB(80.0,80.0,80.0,30.0),
                ));
              },
            ),
            SizedBox(width:2.0),
            GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width/2-1.0,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(50.0,20.0,50.0,20.0),
                    child: Text(
                      "Buy Now",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  users
                      .doc(getUserID())
                      .collection('orders')
                      .doc()
                      .set({
                    'total price': price,
                    'contents': [title, price],
                  })
                      .then((value) => print("Product Added"))
                      .catchError((error) =>
                      print("Failed to add product: $error"));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "Ordered",
                      textAlign: TextAlign.center,
                    ),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.fromLTRB(80.0,80.0,80.0,30.0),
                  ));
                }
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 350.0,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: const Offset(5.0, 5.0),
                          blurRadius: 8.0,
                          spreadRadius: 2.0,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ),
                      ],

                ),
                      child: Image.network(image != ''
                          ? '$image'
                          : 'https://www.yorkshirecareequipment.com/wp-content/uploads/2018/09/no-image-available.jpg?x87029',
                      width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      '$title',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.0,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      '\$$price',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    Text(
                      '$category',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                      ),

                    ),
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        '$desc',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),

                  ],
                ),
        ),
        ),

    );
  }
}
