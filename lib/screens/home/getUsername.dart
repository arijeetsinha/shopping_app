import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/shared/loading.dart';



  String getUserID() {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    return _firebaseAuth.currentUser!.uid;
  }


  Widget getUsername(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(getUserID()).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Text(
            "Hello ${data['username']}!",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 25.0,
              color: Colors.blueAccent,
            ),
          );
        }

        return Loading();
      },
    );
  }
