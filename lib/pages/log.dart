import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:stay_hydrated_app/notification_services.dart';

class LogPage extends StatefulWidget {
  final personalData;
  final calendarData;
  const LogPage(
      {super.key, required this.personalData, required this.calendarData});

  @override
  State<LogPage> createState() => _LogPageState();
}

Widget logRecord(logData) {
  return Container(
      child: Column(
    children: [
      const SizedBox(
        height: 8,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(logData['drink'], //"Water",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Text(
                      DateFormat('hh:mm a')
                          .format(DateTime.parse(logData['time']))
                          .toString(),
                      //logData[1], //"09:00 AM",
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.normal)),
                  const SizedBox(width: 8),
                  Text("${logData['temperature'] ?? 32} 'F",
                      //logData[1], //"09:00 AM",
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.normal))
                ],
              )
            ],
          ),
          Text(
            "${logData['quantity']} mL", //"100 mL",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          )
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Divider(
        height: 2,
      )
    ],
  ));
}

class _LogPageState extends State<LogPage> {
  Map<dynamic, dynamic> log = {};
  var now = DateTime.now();
  var todayDate = DateTime.now().toString().split(" ")[0].replaceAll("-", "");
  DatabaseReference calendarRef = FirebaseDatabase.instance
      .ref('users')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child("calendar");

  Stopwatch stopwatch = Stopwatch();
  bool isStarted = false;
  var timerButton = "Start";
  String timerText = "0:00:00";

  Duration duration = Duration();
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // log[0] = ["Water", "09:00 AM", "100 mL"];
    // log[1] = ["Water", "10:00 AM", "250 mL"];
    // log[2] = ["Water", "11:00 AM", "350 mL"];
    // log[3] = ["Water", "12:00 AM", "500 mL"];
    // log[4] = ["Water", "01:00 PM", "250 mL"];
  }

  void incrementTimer() {
    var seconds = 1;
    setState(() {
      final secs = duration.inSeconds + seconds;

      //Call Notification every 15 minutes
      if (secs % (15) == 0) {
        NotificationServices().sendNotifications(
            title: "Workout Drink Alert", body: "Drink a cup of water");
      }
      duration = Duration(seconds: secs);
    });
  }

  void updateWorkoutData(Duration d) {
    // final snapshot = calendarRef
    //     .child(todayDate.toString())
    //     .child("workout")
    //     .child("duration")
    //     .get();
    // if (double.parse(prevValue) > d.inMinutes) {}
    if (d.inMinutes != 0) {
      calendarRef
          .child(todayDate.toString())
          .child("workout")
          .update({"duration": d.inMinutes});
    }
  }

  Widget workoutCard() {
    String digits(int n) => n.toString().padLeft(2, '0');
    final hours = digits(duration.inHours);
    final minutes = digits(duration.inMinutes.remainder(60));
    final seconds = digits(duration.inSeconds.remainder(60));
    // if (int.parse(seconds) % 15 == 0) {
    //   NotificationServices().sendNotifications(
    //       title: "Workout Drink Alert", body: "Drink a cup of water");
    // }
    timerText = "$hours:$minutes:$seconds";
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Workout Timer",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              CupertinoButton(
                  child: const Text(
                    "Reset",
                    style: TextStyle(color: Color(0xFF4988E7)),
                  ),
                  onPressed: () {
                    updateWorkoutData(duration);
                    setState(() {
                      timer?.cancel();
                      duration = Duration();
                      isStarted = false;
                      timerButton = "Start";
                    });
                  })
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timerText,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              GestureDetector(
                onTap: () {
                  if (isStarted) {
                    timer?.cancel();
                    updateWorkoutData(duration);
                    //NotificationServices().cancelNotification(1000);
                    //stopwatch.stop();
                    //stopwatch.reset();
                  } else {
                    //NotificationServices().sendPeriodicNotifications(id: 1000);
                    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                      incrementTimer();
                    });
                    //stopwatch.start();
                    //updateTime();
                  }
                  setState(() {
                    isStarted = !isStarted;
                    timerButton = isStarted ? "Stop" : "Start";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 8, bottom: 8),
                  decoration: const BoxDecoration(
                      color: Color(0xFF4988E7),
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                  child: Text(timerButton,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        //toolbarHeight: 60,
        //systemOverlayStyle: SystemUiOverlayStyle.dark,
        systemOverlayStyle: const SystemUiOverlayStyle(
          //systemNavigationBarColor: Colors.blue, // Navigation bar
          statusBarColor: Colors.transparent, // Status bar
          statusBarIconBrightness: Brightness.dark,
        ),

        title: const Padding(
          padding: EdgeInsets.only(left: 4, top: 4),
          child: Text(
            'Workout',
            style: TextStyle(
                fontSize: 20,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
        ),
        //backgroundColor: Color(0xFFF6F6F6),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              workoutCard()
              // const Text("Drink Log",
              //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              // for (var i = 0; i < log.length; i++) logRecord(log[i]),
              //Firebase List
              /*
              FirebaseAnimatedList(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                key: UniqueKey(),
                //query: mList[dropdownValue],
                query: personalDataRef
                    .child('calendar')
                    .child(todayDate)
                    .child("log"),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  print("SnapShot:  ${index}");

                  Map? logDetails = snapshot.value as Map?;
                  return logRecord(logDetails);
                },
              ),
            */
            ],
          ),
        ),
      )),
    );
  }
}
