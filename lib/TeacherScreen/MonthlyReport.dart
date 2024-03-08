// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:attendance/Methods/capitilize.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io'; // Import the dart:io library for file operations
import 'package:path_provider/path_provider.dart';
import '../Auth/db.dart';
import '../Methods/getTokenData.dart';
import '../Methods/showMessage.dart';

class MonthlyReport extends StatefulWidget {
  const MonthlyReport({Key? key}) : super(key: key);

  @override
  State<MonthlyReport> createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  List<dynamic> classList = [];
  List<dynamic> subjectList = [];
  List<dynamic> monthlyReport = [];
  int? selectedIndex;
  List<String> monthList = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List<String> yearList = [
    "2024",
    "2025",
    "2026",
    "2027",
    "2028",
    "2029",
    "2030",
  ];

  String? _selectedOption;
  String? _selectedSubject;
  String? _selectMonth;
  String? _selectYear;
  bool loadrepott = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      String schoolId = await getSchoolId();
      Response response =
          await dio.get("http://192.168.1.80:5000/api/teacher/$schoolId/class");

      if (response.statusCode == 200) {
        setState(() {
          classList = response.data['data'];
        });
      } else {
        showToast('${response.data['message']}');
      }
    } catch (e) {
      showToast("$e");
      print("$e");
    }
  }

  Future<void> fetchMonthlyReport() async {
    try {
      String teacherId = await getId();
      String schoolId = await getSchoolId();

      String api =
          "$_selectYear-${selectedIndex}/${schoolId}/${teacherId}/${_selectedOption}/${_selectedSubject}";
      Response response = await dio
          .get('http://192.168.1.80:5000/api/teacher/monthreport/$api');
      if (response.statusCode == 200) {
        monthlyReport = response.data['attendance'];
        setState(() {
          loadrepott = true;
        });
        print(monthlyReport);
      }
    } catch (e) {}
  }

  Future<void> fetchSubjects() async {
    try {
      String schoolId = await getSchoolId();
      Response response = await dio.get(
          'http://192.168.1.80:5000/api/teacher/$schoolId/$_selectedOption');

      if (response.statusCode == 200) {
        setState(() {
          subjectList = response.data['data'];
        });
      } else {
        showToast('${response.data['message']}');
      }
    } catch (e) {
      showToast("$e");
      print("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Monthly Attendence Report",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF580778),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedOption,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedOption = newValue;
                              fetchSubjects();
                            });
                          }
                        },
                        items: classList.map((classes) {
                          String item = classes['class_name'];
                          String id = classes['class_id'].toString();
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(Capitalize(item)),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: "Select Class List",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a Class";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedSubject = newValue;
                            });
                          }
                        },
                        items: subjectList.map((subject) {
                          String item = subject['subject_name'];
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(capitalizeEachWord(item)),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: "Select Subject List",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a Subject";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectMonth,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectMonth = newValue;
                            });

                            selectedIndex = monthList.indexOf(newValue) + 1;
                            print("Selected month index: $selectedIndex");
                          }
                        },
                        items: monthList.map((month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: "Select Month",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a Month";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectYear,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectYear = newValue;
                            });
                          }
                        },
                        items: yearList.map((year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(year),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: "Select Year",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a Year";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: ElevatedButton(
                  onPressed: () {
                    fetchMonthlyReport();
                  },
                  child: Text("Get Report"),
                ))
              ],
            ),
            loadrepott
                ? Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Percent',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: List<DataRow>.generate(
                          monthlyReport.length,
                          (index) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(capitalizeEachWord(
                                    monthlyReport[index]['name'])),
                              ),
                              DataCell(
                                Text(
                                  double.parse(monthlyReport[index]['percent'])
                                          .toStringAsFixed(2) +
                                      "%",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
