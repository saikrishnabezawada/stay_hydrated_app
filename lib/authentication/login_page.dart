import 'package:stay_hydrated_app/authentication/user_personal_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../pages/base.dart';
//import 'package:stay_hydrated_app/pages/base.dart';

//import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  DatabaseReference ref = FirebaseDatabase.instance.ref();

  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    //     .then((value) {
    //   checkIsRegistered(context, value?.id);
    // });

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
  }

  void checkIsRegistered(context, userid) async {
    DatabaseReference personalDataRef = FirebaseDatabase.instance
        .ref('users')
        .child(userid)
        .child('personal_data')
        .child('isRegistered');

    final snapshot = await personalDataRef.get();
    //Map<dynamic, dynamic> data = snapshot as Map;
    print("-----> Login Page Checking Snapshot");
    //&& bool.parse(data['isRegistered'])== true
    if (snapshot.exists) {
      print("-------> Login Page Snapshot exists");
      print("Login Page Snapshot Data: ${snapshot.value}");

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) {
        return const Base();
      }));
    }
    //print(snapshot.value);
    else {
      //print('No data available.');
      print("Login Page SnapShot Not Exists");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) {
        return const UserPersonalDataPage();
      }));
    }
  }

  @override
  void dispose() {
    // Helps for Memory Management as we are targeting multiple Platforms
    // ignore: todo
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: <Widget>[
                    //Title of Screen
                    const Text(
                      'Welcome To',
                      style:
                          TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Stay Hydrated App',
                      style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF4988E7),
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 120),

                    const Text(
                        'Let’s monitor you fluid intake and avoid dehydration',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFA1A1A1),
                        )),

                    const SizedBox(
                      height: 80.0,
                    ),
/*
                    //Login Fields
                    //Email
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ThemeData().colorScheme.copyWith(
                              primary: const Color(0xFF4988E7),
                            ),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(213, 213, 213, 0.60)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF4988E7)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.person),

                          // prefix: Text('Mr. '),
                          // suffix: Text('@gmail.com'),
                          hintText: 'Enter Email',
                          filled: true,
                          fillColor: const Color.fromRGBO(213, 213, 213, 0.60),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    //Password Field
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ThemeData().colorScheme.copyWith(
                              primary: const Color(0xFF4988E7),
                            ),
                      ), //For changing ICON color and CURSOR color
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF4988E7)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.password),

                          // prefix: Text('Mr. '),
                          // suffix: Text('@gmail.com'),
                          hintText: 'Enter Password',
                          filled: true,
                          fillColor: const Color.fromRGBO(213, 213, 213, 0.60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    //Forget Password
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      InkWell(
                        focusColor: Colors.white,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   //return const ForgotPasswordPage();
                          // }));
                        },
                        child: const Text(
                          'forgot Password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]),

                    const SizedBox(
                      height: 20,
                    ),
                    //Buttons
                    //SignIn Button with Email Password
                    GestureDetector(
                      //onTap: signIn,
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFF4988E7),
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.all(20),
                        child: const Center(
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      'Or continue with',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
    */
                    const SizedBox(
                      height: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        //signInWithGoogle()
                        print("Clicked Sign in with Google Button");

                        signInWithGoogle().then((value) {
                          //checkIsRegistered(context, value.user!.uid);

                          print("======> Email:   ${value.user!.email}");
                          // ref.child("users").child(value.user!.uid).update(
                          //     {"personal_data/userid": value.user!.uid});
                          print("====>Uid: ${value.user!.uid}");
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFF4988E7),
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.all(20),
                        child: const Center(
                          child: Text(
                            'Sign In With Google',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    /*
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          //onTap: widget.showRegisterPage,
                          child: const Text(
                            'Not a member? Sign Up here',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                    */
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
