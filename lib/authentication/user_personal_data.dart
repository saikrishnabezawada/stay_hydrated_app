import 'package:stay_hydrated_app/authentication/personalized_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPersonalDataPage extends StatefulWidget {
  //final VoidCallback showRegisterPage;
  const UserPersonalDataPage({super.key});

  @override
  State<UserPersonalDataPage> createState() => _UserPersonalDataPageState();
}

class _UserPersonalDataPageState extends State<UserPersonalDataPage> {
  var weightDropdownValue;
  var weightTypeList = ["Kg(s)", "Lb(s)"];
  var activeDropdownValue;
  var activeTypeList = [
    "Not very active",
    "Moderately active",
    "Active",
    "Very active"
  ];
  var nameController = TextEditingController();
  var ageController = TextEditingController();
  var weightController = TextEditingController();
  @override
  void initState() {
    activeDropdownValue = activeTypeList.first;
    weightDropdownValue = weightTypeList.first;

    super.initState();
  }

  Widget customTextField(
      title, TextInputType inputKeyboardType, inputController,
      {width = double.infinity}) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, //"What's Your Name",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          decoration: const BoxDecoration(
              color: Color(0x55D5D5D5),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          //Text Field
          child: TextField(
            controller: inputController,
            keyboardType: inputKeyboardType,
            textAlign: TextAlign.start,
            cursorColor: const Color(0xFF000000),
            style: const TextStyle(
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Color(0xFF000000)),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(20.0),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Tell us something about you',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              ),
              //const SizedBox(height: 64),
              Column(
                children: [
                  customTextField(
                      "What's your name ?", TextInputType.name, nameController),
                  const SizedBox(height: 16),
                  customTextField(
                      "What's your age ?", TextInputType.number, ageController),
                  const SizedBox(height: 16),
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "What's Your Weight?",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            //flex: 2,
                            child: Container(
                              width: 150,
                              height: 60,
                              decoration: const BoxDecoration(
                                  color: Color(0x55D5D5D5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: TextField(
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.start,
                                cursorColor: const Color(0xFF000000),
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                                decoration: const InputDecoration(
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
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              //width: 120,
                              height: 60,
                              decoration: const BoxDecoration(
                                  color: Color(0x55D5D5D5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: DropdownButton<String>(
                                alignment: Alignment.centerRight,
                                underline: const SizedBox(),
                                value: weightDropdownValue,
                                icon: const Icon(Icons.arrow_drop_down),
                                elevation: 16,
                                style:
                                    const TextStyle(color: Colors.deepPurple),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    weightDropdownValue = value!;
                                  });
                                },
                                items: weightTypeList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "How active are you?",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                            color: Color(0x55D5D5D5),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: DropdownButton<String>(
                          //alignment: Alignment.centerRight,
                          underline: const SizedBox(),
                          value: activeDropdownValue,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              activeDropdownValue = value!;
                            });
                          },
                          items: activeTypeList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  //const SizedBox(height: 24),
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
                      "name": nameController.text,
                      "age": ageController.text,
                      "weight": weightController.text,
                      "weightMeasurementUnit": weightDropdownValue,
                      "userid": FirebaseAuth.instance.currentUser!.uid,
                    });
                  }
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (builder) {
                    return const PersonalizedSettingsPage();
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
                        "Continue",
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
