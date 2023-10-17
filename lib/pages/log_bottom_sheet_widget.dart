import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:stay_hydrated_app/location.dart';

class LogBottomSheetWidget extends StatefulWidget {
  final personalData;
  final calendarData;
  const LogBottomSheetWidget(
      {super.key, required this.personalData, required this.calendarData});

  @override
  State<LogBottomSheetWidget> createState() => _LogBottomSheetWidgetState();
}

class _LogBottomSheetWidgetState extends State<LogBottomSheetWidget> {
  int? chipId = 0;
  var chipList = [100, 150, 250, 500, 750, 1000];
  var fluidDropdownList = ["Coffee", "Juice", "Others"];
  var fluidTypeDropdownValue; //= fluidDropdownList.first;
  var currentFluidIntakeValue;

  // int? chipId = 0;
  // var chipList = [100, 150, 250, 500, 750, 1000];
  var selectedQuantityChoiceChip;
  var fluidQuantityController = TextEditingController();
  DatabaseReference personalDataRef = FirebaseDatabase.instance
      .ref('users')
      .child(FirebaseAuth.instance.currentUser!.uid);
  var temperature = "";
  @override
  void initState() {
    print("Email Id: ${FirebaseAuth.instance.currentUser!.email}");
    currentFluidIntakeValue = chipList.first;
    if (widget.personalData['customDrinkQuantities'] != null) {
      if (widget.personalData['customDrinkQuantities']
          .toString()
          .contains(',')) {
        List<int> customList = [];
        for (var q in widget.personalData['customDrinkQuantities']
            .toString()
            .split(',')) {
          customList.add(int.parse(q));
        }
        chipList = customList;
      }
    }
    fluidTypeDropdownValue = fluidDropdownList.first;
    fluidQuantityController.text = currentFluidIntakeValue.toString();

    getOutsideTemperature();
    //getPersonalData();
    // TODO: implement initState
    super.initState();
  }

  Future<void> getOutsideTemperature() async {
    try {
      var location = Location().getCurrentLocation();
      // Make an API call to retrieve the outside temperature
      var url =
          'https://api.weatherapi.com/v1/current.json?key=d71a732879f74239a4b31105230406&q=$location';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var temper = data['current']['temp_f'].toString();
        setState(() {
          temperature = temper;
        });
        //return temper.toDouble().toString();
      } else {
        throw Exception('Failed to fetch temperature');
      }
    } catch (e) {
      throw Exception('Failed to fetch temperature: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return addDrinkLog();
  }

  Widget addDrinkLog() {
    return Material(
      child: Container(
        width: double.infinity,
        height: 600,
        margin: EdgeInsets.only(top: 64),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        )),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "How much amount of fluid you consumed?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   "Fluid Type",
                  //   style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.normal,
                  //       color: Color.fromRGBO(0, 0, 0, 0.40)),
                  // ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add Quantity",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 32, right: 24),
                          decoration: const BoxDecoration(
                              color: Color(0x55D5D5D5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Wrap(
                            children: [
                              Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            currentFluidIntakeValue -= 50;
                                            fluidQuantityController.text =
                                                currentFluidIntakeValue
                                                    .toString();
                                          });
                                        },
                                        child: const Icon(Icons.remove_circle)),
                                    Container(
                                      width: 120,
                                      child: TextFormField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                signed: true, decimal: true),
                                        textInputAction: TextInputAction.done,
                                        //maxLength: 10,
                                        // inputFormatters: [
                                        //   FilteringTextInputFormatter.digitsOnly
                                        // ],
                                        decoration: const InputDecoration(
                                            border: InputBorder.none),
                                        textAlign: TextAlign.center,
                                        controller: fluidQuantityController,
                                        //cursorHeight: 12.0,
                                        //keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            currentFluidIntakeValue += 50;
                                            fluidQuantityController.text =
                                                currentFluidIntakeValue
                                                    .toString();
                                          });
                                        },
                                        child: const Icon(
                                            Icons.add_circle_outline))
                                  ]),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 5.0,
                    children: List<Widget>.generate(
                      chipList.toSet().toList().length, //3,
                      (int index) {
                        return ChoiceChip(
                          label: Text('${chipList[index]} mL'),
                          selected: chipId == index,
                          onSelected: (bool selected) {
                            //onChipSelected(index);

                            setState(() {
                              //Chip Id
                              chipId = selected ? index : 0;
                              // Update Intake value to Current Chip Value
                              currentFluidIntakeValue = chipList[chipId!];
                              fluidQuantityController.text =
                                  chipList[chipId!].toString();
                              chipList = chipList.toSet().toList();
                            });
                          },
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              GestureDetector(
                onTap: () {
                  var now = DateTime.now();
                  var todayDate =
                      now.toString().split(" ")[0].replaceAll("-", "");
                  personalDataRef
                      .child('calendar')
                      .child(todayDate)
                      .child("log")
                      .push()
                      .update({
                    "drink": "Water",
                    "time": now.toString(),
                    "quantity": fluidQuantityController.text,
                    "temperature": temperature,
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.only(left: 24, right: 24),
                  width: double.infinity,
                  height: 60,
                  decoration: const BoxDecoration(
                      color: Color(0xFF4988E7),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: const Center(
                      child: Text(
                    "Done",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
