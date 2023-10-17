import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stay_hydrated_app/notification_services.dart';
import 'package:stay_hydrated_app/pages/log.dart';
import 'package:stay_hydrated_app/pages/log_bottom_sheet_widget.dart';
import 'package:stay_hydrated_app/pages/profile.dart';
import 'package:stay_hydrated_app/pages/statistics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stay_hydrated_app/pages/home_page.dart';

import '../authentication/user_personal_data.dart';

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  final user = FirebaseAuth.instance.currentUser;
  int currentPageIndex = 0;
  DatabaseReference personalDataRef = FirebaseDatabase.instance
      .ref('users')
      .child(FirebaseAuth.instance.currentUser!.uid);

  // Map? personalData = {
  //   "age": "",
  //   "customDrinkQuantities": "150,250,500,750,1000",
  //   "customRemainders": "09:00,10:30",
  //   "goalIntake": "3500",
  //   "goalIntakeMeasumentUnit": "mL",
  //   "isRegistered": true,
  //   "name": "Sai Krishna",
  //   "userid": "",
  //   "weight": "",
  //   "weightMeasurementUnit": "Kg(s)"
  // };
  Map? personalData = {};
  Map? calendarData = {};

  void _onItemSelected(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  void initState() {
    print("-----On Base Page-----");
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      // Some android/ios specific code
      personalDataRef.keepSynced(true);
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }

    getPersonalData();
    getCalendarData();
    super.initState();
  }

  void getPersonalData() {
    personalDataRef.child('personal_data').onValue.listen((event) {
      
      Map? data = event.snapshot.value as Map?;
      setState(() {
        if (data != null) {
          print("BP Collected New Data");
          personalData = data;
          print("Base Page : Personal Data: $personalData");
        } else {
          print("BP Data is Null: ${data}");
        }
        // if (data == null) {
        //   Navigator.push(context, MaterialPageRoute(builder: (builder) {
        //     return const UserPersonalDataPage();
        //   }));
        //   //personalData = data;
        // } else {
        //   personalData = data;
        // }
      });
      
      
    });
  }

  void getCalendarData() {
    print("------------Calender Value Updated--------------");
    personalDataRef.child('calendar').onValue.listen((event) {
  
        Map? data = event.snapshot.value as Map?;
        if(mounted){
          setState(() {
            calendarData = data;
            //print("Base Page Calendar Data: -->> ${calendarData}");
          });
        }
      
    });
    print("------------Calender Value Updated END--------------");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: currentPageIndex,
          children: <Widget>[
            HomePage(
              personalData: personalData,
              calendarData: calendarData,
            ),
            LogPage(
              personalData: personalData,
              calendarData: calendarData,
            ),
            StatisticsPage(
              personalData: personalData,
              calendarData: calendarData,
            ),
            ProfilePage(
              personalData: personalData,
              calendarData: calendarData,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xff5F81DA),
            child: const Icon(Icons.add),
            onPressed: () async {
              //await FirebaseAuth.instance.signOut();
              var now = DateTime.now();
              NotificationServices()
                  .checkTimeStamps(Time(now.hour, now.minute));
              // print(now.toUtc());
              // print(now.toUtc().toLocal());
              // print(now.toLocal());

              showCupertinoModalPopup(
                  context: context,
                  builder: ((context) {
                    return LogBottomSheetWidget(
                      personalData: personalData,
                      calendarData: calendarData,
                    );
                  }));
            }),
        //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        //extendBody: true,
        bottomNavigationBar: bottomNavigationBar);
  }

  Widget get bottomNavigationBar {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentPageIndex,
        onTap: _onItemSelected,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: const Color(0xff5F81DA),
        unselectedItemColor: const Color(0xFFD0D0D0),
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk_outlined),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
