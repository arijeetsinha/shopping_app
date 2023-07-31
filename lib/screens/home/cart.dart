import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/screens/home/orders.dart';
import 'package:shopping_app/screens/home/productsDisplay.dart';
import 'package:shopping_app/shared/loading.dart';

import 'getUsername.dart';
import 'home.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String getUserID() {
    return _firebaseAuth.currentUser!.uid;
  }

  double sum = 0.0;
  List itemList = [];

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(getUserID())
          .collection('cart')
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
              "Shopping Cart",
              style: TextStyle(
                color:Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0.0,
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
                        Navigator.pop(context);

                      }),
                  ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Manage Your Products'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductsDisplay()),
                        );
                      }),
                ],
              )),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    sum = sum + data['price'];
                    itemList += [
                      data['title'],
                      data['price'],
                    ];
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: const Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ),
                          ]),
                      margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                      child: ListTile(
                        leading: data['image'] == ''
                            ? Image.asset('assets/noimage.jpg')
                            : Image.network(data['image']),
                        title: Text(data['title']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${data['price'].toString()}'),
                            SizedBox(width:2.0),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: (){
                                setState(() {
                                  sum=0;
                                });
                                users
                                    .doc(getUserID())
                                    .collection('cart')
                                    .doc(data['title'])
                                    .delete()
                                    .then((value) => print("Product Deleted"))
                                    .catchError(
                                        (error) => print("Failed to delete product"));
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      "Deleted from Cart",
                                      textAlign: TextAlign.center,
                                    ),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.fromLTRB(80.0,80.0,80.0,30.0),
                                ));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20.0),

                child: ListTile(
                  leading: Text(
                    'Total',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                    ),
                  ),
                  trailing:
                      Text(
                        '\$ $sum',
                        style: TextStyle(fontSize: 20.0),
                      ),
                ),
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6.0,0.0,6.0,6.0),
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width*4/5,
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      border: Border.all(
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'Order',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  if ((snapshot.data!).docs.length != 0) {
                    users
                        .doc(getUserID())
                        .collection('orders')
                        .doc()
                        .set({
                      'total price': sum,
                      'contents': itemList,
                    })
                        .then((value) => print("Product Added"))
                        .catchError((error) =>
                        print("Failed to add product: $error"));
                    setState(() {
                      sum = 0;
                    });
                    var collection = FirebaseFirestore.instance
                        .collection('users')
                        .doc(getUserID())
                        .collection('cart');
                    var snapshots = await collection.get();
                    for (var doc in snapshots.docs) {
                      doc.reference.delete();
                    }
                    setState(() {
                      sum = 0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "Items Ordered",
                        textAlign: TextAlign.center,
                      ),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.fromLTRB(80.0,80.0,80.0,30.0),
                    ));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
