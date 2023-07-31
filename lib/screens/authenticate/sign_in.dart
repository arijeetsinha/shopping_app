import 'package:shopping_app/services/auth.dart';
import 'package:shopping_app/shared/constants.dart';
import 'package:shopping_app/shared/loading.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32.0,
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
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
                            decoration: textInputDecoration.copyWith(
                                hintText: "Password"),
                            validator: (val) => val!.length < 6
                                ? "Enter a password 6+ chars long"
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
                                dynamic result =
                                    await _auth.signInWithEmailAndPassword(
                                        email, password);
                                if (result == null) {
                                  setState(() {
                                    error =
                                        "Could not sign in with those credentials";
                                    loading = false;
                                  });
                                }
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.pink[400]),
                            ),
                            child: Text(
                              "Sign In",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                          Text(
                            error,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          widget.toggleView();
                        },
                        icon: Icon(Icons.person),
                        label: Text("Create New Account")),
                  ],
                ),
              ),
            ),
          );
  }
}
