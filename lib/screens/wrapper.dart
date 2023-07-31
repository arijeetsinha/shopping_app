import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/user.dart';
import 'package:shopping_app/screens/authenticate/authenticate.dart';
import 'package:shopping_app/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserID?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
