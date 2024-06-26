import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/widgets/welcomescreen2.dart';
import 'ui/views/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<FirebaseUser>(context);
    print(user);

    // return either the Home or Menu widget
    if (user == null){
      return HomeScreen();
    } else {
      return WelcomeScreen2();
    }

  }
}
