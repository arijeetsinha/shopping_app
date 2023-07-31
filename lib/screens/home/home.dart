import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/models/product.dart';
import 'package:shopping_app/screens/home/cart.dart';
import 'package:shopping_app/screens/home/individualDisplay.dart';
import 'package:shopping_app/screens/home/orders.dart';
import 'package:shopping_app/screens/home/productsDisplay.dart';
import 'package:shopping_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/shared/constants.dart';
import 'package:shopping_app/shared/loading.dart';
import 'package:shopping_app/screens/home/getUsername.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  bool favorite = false;
  bool cartshow = false;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String getUserID() {
    return _firebaseAuth.currentUser!.uid;
  }


  List favo(List h) {
    h.remove(getUserID());
    return h;
  }

  void choiceAction(String choice) {
    if (choice == Constants.Favorite) {
      setState(() {
        favorite = true;
      });
    } else if (choice == Constants.All) {
      setState(() {
        favorite = false;
      });
    }
  }

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('products').snapshots();

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Product>>.value(
      value: DatabaseService().products,
      initialData: [],
      child: Container(
        constraints: const BoxConstraints.expand(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            title: Text(
                "My Shop",
                style: TextStyle(
                  color:Colors.black,
                ),
            ),
            elevation: 0.0,
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: choiceAction,
                itemBuilder: (BuildContext context) {
                  return Constants.choices.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
              Stack(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Cart()),
                      );
                    },
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 0.0),
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          color: Colors.orange, shape: BoxShape.circle),
                      child: StreamBuilder(
                          stream: users
                              .doc(getUserID())
                              .collection('cart')
                              .snapshots(),
                          builder: (context, snapshot) {
                            int _totalItems = 0;
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              List _documents =
                                  (snapshot.data! as QuerySnapshot).docs;
                              _totalItems = _documents.length;
                            }
                            return Text("$_totalItems");
                          })),
                ],
              ),
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
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                      leading: Icon(Icons.card_membership),
                      title: Text('Orders'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Orders()),
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
                  ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Logout'),
                      onTap: () async {
                        await _auth.signOut();
                      })
                ],
              )),
          body: StreamBuilder<QuerySnapshot>(
            stream: favorite
                ? FirebaseFirestore.instance
                    .collection('products')
                    .where('fav', arrayContains: getUserID())
                    .snapshots()
                : _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading();
              }

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.count(
                  crossAxisCount: 1,
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return GestureDetector(
                        child: Container(
                          width:100.0,
                          height:50.0,
                          margin: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              border: Border.all(),
                              ),
                          child: Column(children: <Widget>[
                            Image.network(data['image'] == ''
                                ? "https://www.yorkshirecareequipment.com/wp-content/uploads/2018/09/no-image-available.jpg?x87029"
                                : data['image'],
                              width:325.0,
                              height:254.0,
                            ),
                            Container(
                              height:75.0,
                              color: Colors.cyanAccent,
                              child: ListTile(
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\$${data['price'].toString()}',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight:FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    data['title'],
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight:FontWeight.bold,
                                    ),
                                  ),
                                  leading: IconButton(
                                    icon: Icon(Icons.favorite),
                                    color: data['fav'].contains(getUserID())
                                        ? Colors.red
                                        : Colors.white,
                                    onPressed: () {
                                      products
                                          .doc(data['title'])
                                          .update({
                                            'fav':
                                                data['fav'].contains(getUserID())
                                                    ? favo(data['fav'])
                                                    : data['fav'] +
                                                        [
                                                          getUserID(),
                                                        ]
                                          })
                                          .then((value) => print("Fav updated"))
                                          .catchError((error) =>
                                              print("Error updating fav"));

                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                            "Updated Favorites",
                                            textAlign: TextAlign.center,
                                          ),
                                          duration: Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.fromLTRB(80.0,80.0,80.0,30.0),
                                        )
                                      );
                                    },
                                  ),
                                  trailing: IconButton(
                                    color: Colors.orange,
                                    icon: Icon(Icons.shopping_cart),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(getUserID())
                                          .collection('cart')
                                          .doc(data['title'])
                                          .get()
                                          .then((DocumentSnapshot
                                              documentSnapshot) {
                                        if (documentSnapshot.exists) {
                                          users
                                              .doc(getUserID())
                                              .collection('cart')
                                              .doc(data['title'])
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
                                              .doc(data['title'])
                                              .set({
                                                'title': data['title'],
                                                'price': data['price'],
                                                'category': data['category'],
                                                'desc': data['desc'],
                                                'image': data['image'],
                                              })
                                              .then((value) =>
                                                  print("Product Added"))
                                              .catchError((error) => print(
                                                  "Failed to add product: $error"));
                                        }
                                      });
                                    },
                                  )),
                            ),
                          ]),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IndividualDisplay(
                                    image: data['image'],
                                    desc: data['desc'],
                                    price: data['price'],
                                    category: data['category'],
                                    title: data['title'])),
                          );
                        });
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
