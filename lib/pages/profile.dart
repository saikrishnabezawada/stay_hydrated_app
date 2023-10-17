import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:stay_hydrated_app/authentication/login_page.dart';
// import 'package:stay_hydrated_app/authentication/main_page.dart';
//import 'package:timezone/timezone.dart' as tz;
import 'package:csv/csv.dart';
import '../notification_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:ext_storage/ext_storage.dart';

class ProfilePage extends StatefulWidget {
  final personalData;
  final calendarData;
  const ProfilePage(
      {super.key, required this.personalData, required this.calendarData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool remainderValue = true;
  late Map<dynamic, dynamic> personalData = {};
  List<dynamic> drinkQuantityInputChips = [];
  List<dynamic> timeInputChips = [];
  List<TimeOfDay> remaindersTimeList = [];
  List<List<dynamic>> exportData = [];

  var personalUserData;

  DatabaseReference personalDataRef = FirebaseDatabase.instance
      .ref('users')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child("personal_data");

  //AppData localAppData = AppData();
  @override
  void initState() {
    print("Profile Page: Personal Data: ${widget.personalData}");
    //print("Inside Profile: ${localAppData.personalData.toString()}");

    initLists();

    //startNotifications();
    personalDataRef.keepSynced(true);
    super.initState();
  }

  Future<bool> _requestPermission(Permission permission) async {
    print("Request for permission");
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future writeCSVFile(data) async {
    await _requestPermission(Permission.storage);
    final directory = await getDownloadsDirectory();
    final path = directory!.path;
    final file = await File('$path/data.csv').create(recursive: true);
    await file.writeAsString(data);
    print("Download Started: to: $path");
  }

  getCalendarData() {
    personalDataRef.child('calendar').onValue.listen((event) {
      Map? data = event.snapshot.value as Map?;
    });
  }

  getExportData() async {
    List<List<dynamic>> exportData = [
      ["ID", "Date", "Total Drink(mL)", "Workout Duration(in mins)"]
    ];
    var calData = widget.calendarData;
    if (widget.calendarData == []) {
      final newdata = await personalDataRef.child('calendar').get();
      if (newdata.exists) {
        Map? data = newdata.value as Map?;
        calData = data;
      }
    }
    int i = 1;
    for (var date in calData.keys) {
      //print(date);
      int total = 0;
      var formatDate = DateTime.parse(date).toString().split(" ")[0];
      var duration = 0;
      for (var records in calData[date]['log'].keys) {
        //print("Log: ${map[date]['log'][records]}");
        total +=
            int.parse(calData[date]['log'][records]['quantity'].toString());
      }
      if (calData[date]['workout'] != null) {
        duration = calData[date]['workout']['duration'];
      }

      // print(
      //     "Id: $i Date: $formatDate Total Drink:$total Workout(in minutes): $duration");
      //print([i,formatDate,total,duration]);
      exportData.add([i, formatDate, total, duration]);
      i += 1;
    }
    print("export Data: ${exportData}");
    //String csv = const ListToCsvConverter().convert(exportData);
    String csvData = const ListToCsvConverter().convert(exportData);
    writeCSVFile(csvData);
  }

  void initLists() {
    print("Profile DATA: ${widget.personalData}");
    if (widget.personalData!['customRemainders'].toString().contains(",")) {
      if (timeInputChips.join(',') != widget.personalData['customRemainders']) {
        setState(() {
          timeInputChips = widget.personalData!['customRemainders']
              .split(",")
              .map((x) => x.trim())
              .toList();
        });

        print("Time Chips in initLists: $timeInputChips");
      } else {
        print("Init 1st Else");
        print("-> ${timeInputChips.join(',')}");
        print("-> ${widget.personalData['customRemainders']}");
      }
    }
    if (widget.personalData!['customDrinkQuantities']
        .toString()
        .contains(",")) {
      if (drinkQuantityInputChips.join(',') !=
          widget.personalData['customDrinkQuantities']) {
        setState(() {
          drinkQuantityInputChips = widget
              .personalData!['customDrinkQuantities']
              .split(",")
              .map((x) => x.trim())
              .toList();
        });
      } else {
        print("Init 2nd Else");
        print("-> ${drinkQuantityInputChips.join(',')}");
        print("-> ${widget.personalData['customDrinkQuantities']}");
      }
    }
  }

  initRemaindersIfEmpty() {
    var tempList = [];
    for (int hour = 7; hour <= 21; hour++) {
      var now = DateTime.now();
      var localDateTime =
          DateTime(now.year, now.month, now.day, hour, 0, 0).toLocal();
      var time =
          TimeOfDay(hour: localDateTime.hour, minute: localDateTime.minute);
      tempList.add(time.format(context).toString());
    }
    if (mounted) {
      setState(() {
        timeInputChips = tempList;
      });
      personalDataRef.update(
          {"customRemainders": timeInputChips.toSet().toList().join(',')});
    }
  }

  void startNotifications() {
    List<Time> remaindersTimeList = [];
    for (var time in timeInputChips.toSet().toList()) {
      var list = time.split(":");
      var tempToD =
          TimeOfDay(hour: int.parse(list[0]), minute: int.parse(list[1]));
      // var now = DateTime.now();
      // var dateTime =
      //     DateTime(now.year, now.month, now.day, tempToD.hour, tempToD.minute);
      var notificationTime = Time(tempToD.hour, tempToD.minute);

      remaindersTimeList.add(notificationTime);
    }
    //print("Remainders Time List: >>>> $remaindersTimeList");
    // //Cancel All
    //NotificationServices().cancelAllNotifications();

    //Update All
    NotificationServices().listOfScheduleNotifications(
        title: "Stay Hydrated",
        body: "Hey, It's time to drink water",
        scheduledDateTimeList: remaindersTimeList);
  }

  Widget profileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4988E7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 96,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.personalData!['name'] ?? "", //"Sai Krishna Bezawada",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Age: ${widget.personalData?['age'] ?? ""}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 24),
                    Text(
                        "Weight: ${widget.personalData?['weight'] ?? ""} ${widget.personalData?['weightMeasurementUnit'] ?? ""}",
                        style: const TextStyle(color: Colors.white))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget goalIntakePopUp() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Enter Goal Intake",
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Container(
                width: 220,
                child: const TextField(
                  //cursorHeight: 12.0,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                    fillColor: Color.fromRGBO(213, 213, 213, 0.88),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 24,
              ),
              Container(
                width: 90,
                child: const TextField(
                  //cursorHeight: 12.0,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                    fillColor: Color.fromRGBO(213, 213, 213, 0.88),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          CupertinoButton(child: const Text("Save Changes"), onPressed: () {})
        ],
      ),
    );
  }

/*
void _showDialog(Widget child, context) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => Container(
      height: 216,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 6.0),
      // The Bottom margin is provided to align the popup above the system navigation bar.
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      // Provide a background color for the popup.
      color: CupertinoColors.systemBackground.resolveFrom(context),
      // Use a SafeArea widget to avoid system overlaps.
      child: SafeArea(
        top: false,
        child: child,
      ),
    ),
  );
}
*/

  Future<void> signOut() async {
    print("Logging out");
    await FirebaseAuth.instance.signOut();
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) {
    //   return MainPage();
    // }));
    //await FirebaseAuth.instance.signOut();
  }

  Future showBottomSettingSheet(context) {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(24))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Goal Intake",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Container(
                      width: 200,
                      child: const TextField(
                        //cursorHeight: 12.0,
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: false, signed: true),
                        decoration: InputDecoration(
                          fillColor: Color.fromRGBO(213, 213, 213, 0.88),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    Container(
                      width: 90,
                      child: const TextField(
                        //cursorHeight: 12.0,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          fillColor: Color.fromRGBO(213, 213, 213, 0.88),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 32),
                CupertinoButton(
                  child: const Text('Save Changes'),
                  onPressed: () {
                    setState(() {
                      //_result = 'Agree';
                    });
                    // Then close the dialog
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  showSettingsDialog(alertTitle) {
    var controller = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text(alertTitle),
              content: Material(
                //type: MaterialType.canvas,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        //cursorHeight: 12.0,
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
              actions: [
                // Close the dialog
                // You can use the CupertinoDialogAction widget instead

                CupertinoButton(
                  child: const Text('Save Changes'),
                  onPressed: () {
                    if (alertTitle == "Enter Quantity Per Drink") {
                      print("Drink Quantity Submitted");
                      if (mounted) {
                        setState(() {
                          drinkQuantityInputChips.add(controller.text);
                        });
                        personalDataRef.update({
                          "customDrinkQuantities":
                              drinkQuantityInputChips.toSet().toList().join(',')
                        });
                      }
                    }
                    if (alertTitle == "Enter Goal Intake") {
                      personalDataRef.update({"goalIntake": controller.text});
                    }

                    // Then close the dialog
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
    //controller.dispose();
  }

  Widget goalIntakeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text(
          "Goal Intake",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            showSettingsDialog("Enter Goal Intake");

            //showCupertinoDialog(context: context, builder: builder)
          },
          child: Text(
            "${widget.personalData!['goalIntake'] ?? ''} ${widget.personalData!['goalIntakeMeasumentUnit'] ?? ''}", //"3500 mL",
            style: const TextStyle(
                color: Color(0xFF4988E7), fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    );
  }

  Widget remaindersCard() {
    //bool remainderValue = true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Remainders",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Add time at which you would like to be remainded",
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    // This bool value toggles the switch.
                    value: remainderValue,
                    activeColor: const Color(0xFF4988E7),
                    onChanged: (bool? value) {
                      //This is called when the user toggles the switch.
                      setState(() {
                        remainderValue = value ?? false;
                        if (remainderValue == true) {
                          startNotifications();
                          // NotificationServices().sendPeriodicNotifications(
                          //     title: "Stay Hydrated",
                          //     body: "Time to drink water");
                        } else {
                          NotificationServices().cancelAllNotifications();
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: remainderValue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      //runSpacing: 2.0,
                      children: List<Widget>.generate(timeInputChips.length,
                          (int index) {
                        return Chip(
                          label: Text(timeInputChips[index]),
                          onDeleted: () {
                            if (mounted) {
                              setState(() {
                                timeInputChips.removeAt(index);
                              });
                              personalDataRef.update({
                                "customRemainders":
                                    timeInputChips.toSet().toList().join(',')
                              });
                              startNotifications();
                            }
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? selectedTimeRTL = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Directionality(
                              textDirection: TextDirection.ltr,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: false,
                                ),
                                child: child!,
                              ),
                            );
                          },
                        );
                        if (mounted) {
                          setState(() {
                            timeInputChips
                                .add(selectedTimeRTL!.format(context));
                          });
                          personalDataRef.update({
                            "customRemainders":
                                timeInputChips.toSet().toList().join(',')
                          });
                          startNotifications();
                        }
                      },
                      child: const Center(
                        child: Text(
                          'Add Time',
                          style: TextStyle(
                              color: Color(0xFF4988E7),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget customQuantitiesCard() {
    //bool remainderValue = true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quantity per Drink",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Add all serving sizes you use in your day-to-day life",
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showSettingsDialog("Enter Quantity Per Drink");
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(
                          color: Color(0xFF4988E7),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: List<Widget>.generate(drinkQuantityInputChips.length,
                    (int index) {
                  return Chip(
                    //backgroundColor: const Color(0xFF4988E7),
                    label: Text(drinkQuantityInputChips[index]),
                    /*
                    SizedBox(
                      //color: Colors.white,
                      width: 45,
                      height: 28,
                      child: TextFormField(
                        controller: TextEditingController(
                            text: drinkQuantityInputChips[index].toString()),
                        onFieldSubmitted: (value) {
                          print("-------submitted----------");
                          if (mounted) {
                            setState(() {
                              drinkQuantityInputChips[index] = value;
                            });
                            personalDataRef.update({
                              "customDrinkQuantities": drinkQuantityInputChips
                                  .toSet()
                                  .toList()
                                  .join(',')
                            });
                          }
                        },
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        //autofocus: true,

                        cursorColor: Colors.white,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          suffixStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                          hintMaxLines: 1,
                          hintText: "... ",
                          //suffixText: 'mL',
                          contentPadding: EdgeInsets.only(bottom: 12),
                          border: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    */
                    //Text(drinkQuantityInputChips[index]),
                    onDeleted: () {
                      if (mounted) {
                        setState(() {
                          drinkQuantityInputChips.removeAt(index);
                        });
                        personalDataRef.update({
                          "customDrinkQuantities":
                              drinkQuantityInputChips.toSet().toList().join(',')
                        });
                      }
                    },
                  );
                }),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget measurementsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Measuring Units",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "mL",
              style: TextStyle(
                  color: Color(0xFF4988E7), fontWeight: FontWeight.bold),
            ),
          ]),
    );
  }

  Widget logOutCard() {
    return GestureDetector(
      onTap: () {
        signOut();
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Logout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ]),
      ),
    );
  }

  Widget exportCard() {
    return GestureDetector(
      onTap: () {
        getExportData();
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Export Data",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      initLists();
    });

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
            'Profile',
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
          //padding: const EdgeInsets.all(24),
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 48),
          child: Column(
            children: [
              profileCard(),
              const SizedBox(height: 16),
              goalIntakeCard(),
              const SizedBox(height: 16),
              remaindersCard(),
              const SizedBox(height: 16),
              customQuantitiesCard(),
              const SizedBox(height: 16),
              measurementsCard(),
              
              const SizedBox(height: 16),
              exportCard(),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              logOutCard(),
            ],
          ),
        ),
      )),
    );
  }
}
