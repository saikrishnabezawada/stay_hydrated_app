import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stay_hydrated_app/pages/base.dart';

import '../notification_services.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';

class PersonalizedSettingsPage extends StatefulWidget {
  const PersonalizedSettingsPage({super.key});

  @override
  State<PersonalizedSettingsPage> createState() =>
      _PersonalizedSettingsPageState();
}

class _PersonalizedSettingsPageState extends State<PersonalizedSettingsPage> {
  // Widget addChip(){
  //   return ChoiceChip(label: label, selected: selected)
  // }

  var addChipController = TextEditingController();
  List inputChips = [];
  List timeInputChips = [];
  List drinkQuantityInputChips = [];

  bool remainderValue = true;

  var goalIntakeController = TextEditingController();

  //var goalIntakeList = ["mL", "oZ"];
  List<String> goalIntakeList = <String>["mL", "oZ"];

  late dynamic goalIntakeDropdownValue;

  DatabaseReference personalDataRef = FirebaseDatabase.instance
      .ref('users')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child("personal_data");

  @override
  void initState() {
    goalIntakeDropdownValue = goalIntakeList.first;

    super.initState();
  }

  void addInputChip(chipText) {
    setState(() {
      //inputChips.add(chipText);
      inputChips.add(InputChip(
        label: Text(chipText),
        onPressed: () {},
        onDeleted: () {
          // setState(() {
          //   inputChips.remove(InputChip(label: Text(chipText)));
          // });
        },
      ));
    });
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
                        autofocus: true,
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

  Widget customQuantitiesCard() {
    //bool remainderValue = true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
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

  Widget remaindersCard() {
    //bool remainderValue = true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF6F6F6),
      // extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          //height: MediaQuery.of(context).h,
          //height: double.infinity,
          //margin: const EdgeInsets.only(top: 72),
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(
            // direction: Axis.horizontal,
            // alignment: WrapAlignment.spaceBetween,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "let's personalize app for you",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              ),
              //const SizedBox(height: 64),
              Column(
                children: [
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "What's your goal intake ?",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              width: 220,
                              height: 60,
                              decoration: const BoxDecoration(
                                  color: Color(0x55D5D5D5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: TextField(
                                autofocus: false,
                                controller: goalIntakeController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(),
                                textAlign: TextAlign.start,
                                cursorColor: const Color(0xFF000000),
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Color(0xFF000000)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  contentPadding: EdgeInsets.all(20.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              width: 90,
                              height: 60,
                              decoration: const BoxDecoration(
                                  color: Color(0x55D5D5D5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: DropdownButton<String>(
                                alignment: Alignment.centerRight,
                                underline: const SizedBox(),
                                value: goalIntakeDropdownValue,
                                icon: const Icon(Icons.arrow_drop_down),
                                elevation: 16,
                                style:
                                    const TextStyle(color: Colors.deepPurple),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    goalIntakeDropdownValue = value!;
                                  });
                                },
                                items: goalIntakeList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  /*
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "How frequent do you drink ?",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 220,
                            height: 60,
                            decoration: const BoxDecoration(
                                color: Color(0x55D5D5D5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            child: const TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.start,
                              cursorColor: Color(0xFF000000),
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF000000)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                contentPadding: EdgeInsets.all(20.0),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                          const SizedBox(
                            width: 90,
                            child: TextField(
                              //cursorHeight: 12.0,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                fillColor: Color.fromRGBO(213, 213, 213, 0.88),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  */
                  const SizedBox(height: 24),
                  remaindersCard(),
                  const SizedBox(height: 16),
                  customQuantitiesCard(),
                ],
              ),
              //const SizedBox(height: ,)
              GestureDetector(
                onTap: () {
                  DatabaseReference ref = FirebaseDatabase.instance.ref();
                  DatabaseReference userDataRef;
                  if (FirebaseAuth.instance.currentUser != null) {
                    userDataRef = ref
                        .child("users")
                        .child(FirebaseAuth.instance.currentUser!.uid)
                        .child("personal_data");
                    userDataRef.update({
                      "isRegistered": true,
                      "goalIntake": goalIntakeController.text,
                      "goalIntakeMeasumentUnit": goalIntakeDropdownValue,
                      "customDrinkQuantities":
                          drinkQuantityInputChips.toSet().toList().join(','),
                      "customRemainders":
                          timeInputChips.toSet().toList().join(','),
                    });
                  }
                  print("Reloading");

                  // final SharedPreferences prefs =
                  //     await SharedPreferences.getInstance();
                  // await prefs.setBool('isRegistrationCompleted', true);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (builder) {
                    return const Base();
                  }));
                },
                child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: const BoxDecoration(
                        color: Color(0xff000000),
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: const Center(
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                    )),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
