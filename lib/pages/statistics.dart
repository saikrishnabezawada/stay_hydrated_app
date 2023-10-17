//import 'dart:html';

import 'package:stay_hydrated_app/bar_chart_data_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsPage extends StatefulWidget {
  final personalData;
  final calendarData;
  const StatisticsPage(
      {super.key, required this.personalData, required this.calendarData});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  
  List<BarChartDataModel> barList =
      List<BarChartDataModel>.empty(growable: true);

  var dailyIntakeData = {};
  var personalData = {};
  var chartStartDate = "";
  var chartEndDate = "";
  var goalIntake = 0;

  var start = DateTime.now();
  var end = DateTime.now();

  var months = [
    "0",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "June",
    "July",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  DatabaseReference calendarDataRef = FirebaseDatabase.instance
      .ref('users')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child('calendar');
  DatabaseReference personalDataRef = FirebaseDatabase.instance
      .ref('users')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child('personal_data');

  @override
  void initState() {
    print("INIT Statistics Page");
    getDataList();
    goalIntake = widget.personalData['goalIntake'] == null
        ? 0
        : int.parse(widget.personalData['goalIntake']);
    var temp = getThisWeek(DateTime.now());
    start = temp[0];
    end = temp[1];
    getDataThisWeek(start, end);
    // TODO: implement initState
    super.initState();
  }

  getDataThisWeek(start, end) {
    print("---------- Get data this week--------");
    var data = [];

    for (var i = 0; i <= 6; i++) {
      var index = start
          .add(Duration(days: i))
          .toString()
          .split(' ')[0]
          .replaceAll("-", "");

      data.add((dailyIntakeData[index] ?? "0").toString());
    }
    addBarData(data);
  }

  getDateList(data) {
    print("---------- Get date list--------");
    print(">>>> ${widget.calendarData.toString()}");
    var c = {};
    data?.forEach((var date, var log) {
      var total = 0;
      log.forEach((var log, var data) {
        if (log == "log") {
          data.forEach((var id, var logData) {
            print("${logData}");
            total += int.parse(logData['quantity'].toString()??"0");
          });
        }
      });

      if (total <= int.parse( widget.personalData['goalIntake']??"1000" ) ) {
        c[date] = total;
      } else {
        c[date] = int.parse( widget.personalData['goalIntake']??"1000");
      }
    });

    if (mounted) {
      setState(() {
        dailyIntakeData = c;
        print("---------- Daily Intake Data-------- : $dailyIntakeData");
        var result = getThisWeek(DateTime.now());
        getDataThisWeek(result[0], result[1]);
      });
    }
    //return c;
  }

  void getDataList() {
    print("---------- Get data list--------");
    //getDateList(widget.calendarData);
    calendarDataRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (event.snapshot.exists) {
        print("========> ${data.toString()}");
        getDateList(data);
      }
    });
  }

  void addBarData(data) {
    print("---------- add bar data --------");
    barList = List<BarChartDataModel>.empty(growable: true);
    barList.add(BarChartDataModel(key: "0", value: data[0]));
    barList.add(BarChartDataModel(key: "1", value: data[1]));
    barList.add(BarChartDataModel(key: "2", value: data[2]));
    barList.add(BarChartDataModel(key: "3", value: data[3]));
    barList.add(BarChartDataModel(key: "4", value: data[4]));
    barList.add(BarChartDataModel(key: "5", value: data[5]));
    barList.add(BarChartDataModel(key: "6", value: data[6]));
  }

  List<BarChartGroupData> _chartGroups() {
    List<BarChartGroupData> list =
        List<BarChartGroupData>.empty(growable: true);
    for (var i = 0; i < barList.length; i++) {
      list.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
            width: 16,
            toY: double.parse(barList[i].value!),
            color: const Color(0xFF4988E7))
      ]));
    }
    return list;
  }

  SideTitles get _bottomTitles => SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        String text = '';
        var days = ["Mon", "Tues", "Wed", "Thus", "Fri", "Sat", "Sun"];
        text = days[value.toInt()];

        return Text(
          text,
          style: TextStyle(fontSize: 10),
        );
      });

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);
  getNextWeek() {
    var a = end.add(Duration(days: 1));
    var b = end.add(Duration(days: 7));
    if (mounted) {
      setState(() {
        chartStartDate = "${months[a.month]} ${a.day}";
        chartEndDate = "${months[b.month]} ${b.day}";
        start = a;
        end = b;
      });
    }
    getDataThisWeek(a, b);
    print("Next Week Start: ${months[a.month]} ${a.day}");
    print("Next Week End: ${months[b.month]} ${b.day}");
  }

  getLastWeek() {
    var a = start.subtract(Duration(days: 7));
    var b = start.subtract(Duration(days: 1));
    if (mounted) {
      setState(() {
        chartStartDate = "${months[a.month]} ${a.day}";
        chartEndDate = "${months[b.month]} ${b.day}";
        start = a;
        end = b;
      });
    }
    getDataThisWeek(a, b);
    print("Last Week Start: ${months[a.month]} ${a.day}");
    print("Last Week End: ${months[b.month]} ${b.day}");
  }

  getThisWeek(date) {
    var startOfWeek = getDate(date.subtract(Duration(days: date.weekday - 1)));
    var endOfWeek = getDate(date
        .add(Duration(days: (DateTime.daysPerWeek - date.weekday).toInt())));
    var a = "${months[startOfWeek.month]} ${startOfWeek.day}";
    var b = "${months[endOfWeek.month]} ${endOfWeek.day}";
    if (mounted) {
      setState(() {
        chartStartDate = "${months[startOfWeek.month]} ${startOfWeek.day}";
        chartEndDate = "${months[endOfWeek.month]} ${endOfWeek.day}";
      });
    }
    print('Start of week: ${months[startOfWeek.month]} ${startOfWeek.day}');
    print('End of week: ${months[endOfWeek.month]} ${endOfWeek.day}');
    return [startOfWeek, endOfWeek, a, b];
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
            'Statistics',
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
        child: Container(
          margin: const EdgeInsets.only(left: 24, right: 24, top: 124),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        //getLastWeek(getThisWeek(DateTime.now())[1]);
                        getLastWeek();
                      },
                      child: Icon(Icons.chevron_left_rounded)),
                  Text(
                    "$chartStartDate - $chartEndDate",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                      onTap: () {

                        getNextWeek();
                      },
                      child: Icon(Icons.chevron_right_rounded))
                ],
              ),

              const SizedBox(height: 16),
              
              // Expanded(
              //     flex: 2,
              //     child: Container(
              //       color: Colors.white,
              //       height: 100,
              //       width: 200,
              //     )),

              Container(
                padding: const EdgeInsets.only(top: 24, left: 8, right: 8),
                color: Colors.white,
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
                //decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
                child: BarChart(

                  BarChartData(
                    //maxY: 3500,
                    maxY: int.parse(widget.personalData['goalIntake'] ?? "3500")
                        .toDouble(),
                    backgroundColor: Colors.white,
                    barGroups: _chartGroups(),
                    borderData: FlBorderData(
                        border: const Border(
                            bottom: BorderSide(), left: BorderSide())),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: _bottomTitles,
                      ),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              interval: 500,
                              reservedSize: 48,
                              getTitlesWidget: ((value, meta) {
                                return Text(
                                  value.toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              }))),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
