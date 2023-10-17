// ignore_for_file: prefer_const_constructors, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stay_hydrated_app/authentication/auth_page.dart';
import 'package:stay_hydrated_app/authentication/user_personal_data.dart';
import 'package:stay_hydrated_app/pages/base.dart';
import 'package:stay_hydrated_app/pages/home_page.dart';
import 'package:stay_hydrated_app/authentication/login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isRegistered = false;
  late DatabaseReference personalDataRef;
  // DatabaseReference personalDataRef = FirebaseDatabase.instance
  //     .ref('users')
  //     .child(FirebaseAuth.instance.currentUser!.uid)
  //     .child('personal_data')
  //     .child('isRegistered');
  checkIsRegistered(context, userid) async {
    //Future.delayed(Duration(seconds: 2));
    personalDataRef = FirebaseDatabase.instance
        .ref('users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('personal_data')
        .child('isRegistered');

    final snapshot = await personalDataRef.get();
    //Map<dynamic, dynamic> data = snapshot as Map;
    print("Main Page -----> Checking Snapshot");
    print("Main Page Check isReg: ${snapshot.value}");
    //&& bool.parse(data['isRegistered'])== true
    if (snapshot.exists) {
      print("Main Page -------> Snapshot exists");
      print("Main Page -------> Snapshot Data: ${snapshot.value}");
      // setState(() {
      //   isRegistered = !isRegistered;
      // });
      return true;
    }
    return false;
  }

  @override
  void initState() {
    //personalDataRef.keepSynced(true);
    //checkIsRegistered(context, FirebaseAuth.instance.currentUser?.uid);
    // TODO: implement initState
    //checkIsRegistered(context, FirebaseAuth.instance.currentUser!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //checkIsRegistered(context, FirebaseAuth.instance.currentUser?.uid);
    return Scaffold(
      body: StreamBuilder<User?>(
        //stream: ,
        stream: FirebaseAuth.instance.authStateChanges(),

        builder: (context, snapshot) {
          //Future.delayed(Duration(seconds: 2));
          if (snapshot.hasData) {
            return FutureBuilder(
                future: checkIsRegistered(
                    context, FirebaseAuth.instance.currentUser?.uid),
                builder: (context, snapshot) {
                  //print("Future builder Snap: ${snapshot.toString()}");
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return CircularProgressIndicator();
                  // }
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data != null && snapshot.data == true) {
                      print("----MP Called Base Class-----");
                      return Base();
                    } else {
                      return UserPersonalDataPage();
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                });
          } else {
            print("------MP Called AuthPage Class-----");
            return AuthPage();
          }
        },
      ),
    );
    /*
      return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
     */
  }
}
