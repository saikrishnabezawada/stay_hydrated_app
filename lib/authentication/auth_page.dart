import 'package:stay_hydrated_app/authentication/user_personal_data.dart';
import 'package:flutter/material.dart';
import 'package:stay_hydrated_app/authentication/login_page.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(showRegisterPage: toggleScreens);
      //return const LoginPage();
    } else {
      //toggleScreens();
      return const UserPersonalDataPage();
    }
  }
}
