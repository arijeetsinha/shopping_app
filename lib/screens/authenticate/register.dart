import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/shared/constants.dart';
import 'package:shopping_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/services/auth.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({required this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  String getUserID() {
    return _firebaseAuth.currentUser!.uid;
  }

  //text field state
  String email = '';
  String password = '';
  String error = '';
  String username = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Create New Account",
                        style: TextStyle(
                          fontSize: 32.0,
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      TextFormField(
                        decoration:
                        textInputDecoration.copyWith(hintText: "Username"),
                        validator: (val) =>
                        val!.isEmpty ? "Enter your username" : null,
                        onChanged: (val) {
                          setState(() => username = val);
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: "Email"),
                        validator: (val) =>
                            val!.isEmpty ? "Enter an email" : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: "Password"),
                        validator: (val) => val!.length < 6
                            ? "Enter a password, 6+ chars long"
                            : null,
                        obscureText: true,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => loading = true);
                            dynamic result = await _auth
                                .registerWithEmailAndPassword(email, password);

                            if (result == null) {
                              setState(() {
                                error = "Please enter a valid email";
                                loading = false;
                              });

                            }
                          }
                          users.
                          doc(getUserID()).
                          set({'username':username});
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.pink[400]),
                        ),
                        child: Text(
                          "Register",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        error,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Already Registered? '),
                          GestureDetector(
                            child: Text('Sign In',
                                style: TextStyle(
                                  color: Colors.blue[400],
                                )),
                            onTap: () {
                              widget.toggleView();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
