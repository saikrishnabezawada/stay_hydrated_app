// ignore_for_file: prefer_const_constructors

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class HomePage extends StatefulWidget {
  final personalData;
  final calendarData;
  const HomePage(
      {super.key, required this.personalData, required this.calendarData});

  @override
  State<HomePage> createState() => HomePageState();

  static void getLocalAppData() {}
}

class HomePageState extends State<HomePage> {
  var now = DateTime.now();
  var todayDate = DateTime.now().toString().split(" ")[0].replaceAll("-", "");

  var currentIntake = 0;
  var currentIntakePercentage = 0;
  var goalIntake = 0;

  Map<dynamic, dynamic> personalData = {};
  DatabaseReference personalDataRef = FirebaseDatabase.instance
      .ref('users')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child('calendar')
      .child(DateTime.now().toString().split(" ")[0].replaceAll("-", ""))
      .child("log");
  Map<dynamic, dynamic> log = {};
  // var now = DateTime.now();
  // var todayDate = DateTime.now().toString().split(" ")[0].replaceAll("-", "");
  DatabaseReference todayLogDataRef = FirebaseDatabase.instance
      .ref('users')
      .child(FirebaseAuth.instance.currentUser!.uid);

  @override
  void initState() {
    goalIntake = widget.personalData['goalIntake'] == null
        ? 0
        : int.parse(widget.personalData['goalIntake']);
    personalDataRef.keepSynced(true);
    getPersonalData();
    getTotalDrink(widget.calendarData[todayDate]['log']??{});
    //getTotalDrink();
    super.initState();
  }

   getTotalDrink(records) {
    var total = 0;
    print("--------Home Page Data--------");
    //print(widget.calendarData[todayDate]['log'].toString());
    records.forEach((var a, var b) {
      total += int.parse(b['quantity'].toString());
    });
    if(mounted){
      setState(() {
        if (total <= int.parse( widget.personalData['goalIntake']??"0")   ) {
          currentIntake = total;
          currentIntakePercentage = (currentIntake * 100) ~/ int.parse(widget.personalData['goalIntake']);
        } else {
          currentIntake = int.parse(widget.personalData['goalIntake']??"0");
          currentIntakePercentage = (currentIntake * 100) ~/ int.parse(widget.personalData['goalIntake']??"1");
        }
      });
    }

    return total.toString();
    
  }

  void getPersonalData() {
    // setState(() {
    //   goalIntake = int.parse(widget.personalData['goalIntake']);
    // });
    personalDataRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (event.snapshot.exists) {
        var records = data as Map;
        getTotalDrink(records);
      }
    });
  }

  Widget customContainer(cHeight, cPadding, bRadius, bColor, cChild) {
    return Container(
      //height: cHeight.toDouble(),
      padding: EdgeInsets.only(
          left: cPadding[0].toDouble(),
          right: cPadding[1].toDouble(),
          top: 2,
          bottom: 2),
      constraints: BoxConstraints(
        maxWidth: double.infinity,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(bRadius.toDouble())),
        color: bColor,
      ),
      child: cChild,
    );
  }

  Widget logRecord(logData) {
    return Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(24))),
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
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF6F6F6),
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          centerTitle: false,
          toolbarHeight: 80,
          //systemOverlayStyle: SystemUiOverlayStyle.dark,
          systemOverlayStyle: SystemUiOverlayStyle(
            //systemNavigationBarColor: Colors.blue, // Navigation bar
            statusBarColor: Colors.transparent, // Status bar
            statusBarIconBrightness: Brightness.dark,
          ),

          title: Padding(
            padding: const EdgeInsets.only(left: 8, top: 16),
            child: Text(
              'Hey, ${widget.personalData['name'] ?? ""}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
          //backgroundColor: Color(0xFFF6F6F6),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: SafeArea(
            child: Container(
              color: Color(0xFFF6F6F6),
              padding: EdgeInsets.only(left: 24, right: 24),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 56,
                        ),
                        CircularPercentIndicator(
                          circularStrokeCap: CircularStrokeCap.round,
                          radius: 90.0,
                          lineWidth: 24.0,
                          percent: currentIntakePercentage / 100.0,
                          backgroundColor: Color(0x554988E7),
                          animateFromLastPercent: true,
                          //fillColor: Color(0x884988E7),
                          center: Text(
                            //"100%",
                            "${currentIntakePercentage.toString()}%",
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          progressColor: Color(0xFF4988E7),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Current Intake",
                                  style: TextStyle(
                                      color: Color(0xFFCCCCCC),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  //"${getTotalDrink(widget.calendarData[todayDate]['log']).toString()} ${widget.personalData['goalIntakeMeasumentUnit']}",
                                  "${currentIntake.toString()} ${widget.personalData['goalIntakeMeasumentUnit']}",
                                  //"2000 mL",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 24,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Goal Intake",
                                  style: TextStyle(
                                      color: Color(0xFFCCCCCC),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "${widget.personalData['goalIntake']} ${widget.personalData['goalIntakeMeasumentUnit']}",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 24, bottom: 24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(24))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Drink Log",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900)),
                        FirebaseAnimatedList(
                          scrollDirection: Axis.vertical,
                          reverse: true,
                          shrinkWrap: true,
                          //key: UniqueKey(),
                          //query: mList[dropdownValue],
                          query: todayLogDataRef
                              .child('calendar')
                              .child(todayDate)
                              .child("log"),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (BuildContext context,
                              DataSnapshot snapshot,
                              Animation<double> animation,
                              int index) {
                            //print("SnapShot:  ${index}");

                            Map? logDetails = snapshot.value as Map?;
                            //getTotalDrink(logDetails);
                            return logRecord(logDetails);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 56)
                ],
              ),
            ),
          ),
        ));
  }
}
