import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/screens/authenticate/authenticate.dart';
import 'package:shopping_app/screens/home/productsDisplay.dart';
import 'package:shopping_app/shared/loading.dart';
import 'package:shopping_app/screens/home/getUsername.dart';

import '../../services/auth.dart';
import '../wrapper.dart';
import 'cart.dart';
import 'home.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final AuthService _auth = AuthService();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String getUserID() {
    return _firebaseAuth.currentUser!.uid;
  }

  Text names(List h) {
    int l = h.length;
    int i = 0;
    int num=1;
    String t = '';
    for (i = 0; i < l; i += 2) {
      t += num.toString()+'. '+h[i] + '     \$ ' + h[i + 1].toString() + '\n\n';
      num++;
    }
    return Text(
      t,
      style: TextStyle(
        fontSize: 16.0,
          color: Colors.white,
          fontWeight: FontWeight.bold
      ),
    );
  }

  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(getUserID())
          .collection('orders')
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
              "Your Orders",
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
                        Navigator.pop(context);
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
          body: ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 2.0),
                  color: Colors.blueGrey,
                  boxShadow: [
                  BoxShadow(
                  color: Colors.black26,
                  offset: const Offset(5.0, 5.0),
                  blurRadius: 10.0,
                  spreadRadius: 4.0,
                ),
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ),
                  ]
                ),
                margin: EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Order Value - \$ ${data['total price'].toString()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    ListTile(
                      title: names(data['contents']),
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
