import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/screens/home/addProducts.dart';
import 'package:shopping_app/screens/home/cart.dart';
import 'package:shopping_app/screens/home/updateProduct.dart';
import 'package:shopping_app/shared/loading.dart';

import 'getUsername.dart';
import 'home.dart';
import 'orders.dart';

class ProductsDisplay extends StatefulWidget {
  @override
  _ProductsDisplayState createState() => _ProductsDisplayState();
}

class _ProductsDisplayState extends State<ProductsDisplay> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String getUserID() {
    return _firebaseAuth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(getUserID())
          .collection('products')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            title: Text(
              "Manage Your Products",
              style: TextStyle(
                color:Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0.0,
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProduct()),
                  );
                },
              )
            ],
          ),
          drawer: Drawer(
              backgroundColor: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SafeArea(
                    child: Container(
                      height: 60.0,
                      child: DrawerHeader(
                        child: Container(
                          child:getUsername(context),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.shop),
                    title: Text('Shop'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                  ),
                  ListTile(
                      leading: Icon(Icons.card_membership),
                      title: Text('Orders'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Orders()));
                      }),
                  ListTile(
                      leading: Icon(Icons.shopping_cart),
                      title: Text('Cart'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Cart()),
                        );
                      }
                  ),
                  ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Manage Your Products'),
                      onTap: () {
                        Navigator.pop(context);
                      }),
                ],
              )),
          body: ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                leading: data['image'] == ''
                    ? Image.asset('assets/noimage.jpg')
                    : Image.network(data['image']),
                title: Text(data['title']),
                subtitle: Text(data['price'].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateProduct(
                                  title: data['title'],
                                  desc: data['desc'],
                                  image: data['image'],
                                  category: data['category'],
                                  price: data['price'])),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        users
                            .doc(getUserID())
                            .collection('products')
                            .doc(data['title'])
                            .delete()
                            .then((value) => print("Product Deleted"))
                            .catchError(
                                (error) => print("Failed to delete product"));
                        products
                            .doc(data['title'])
                            .delete()
                            .then((value) => print("Product Deleted"))
                            .catchError(
                                (error) => print("Failed to delete product"));
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
