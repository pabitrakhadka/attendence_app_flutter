import 'package:attendance/Methods/getTokenData.dart';
import 'package:attendance/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance/Methods/showMessage.dart';

import '../Auth/db.dart';

class SchoolAttendance extends StatefulWidget {
  const SchoolAttendance({Key? key}) : super(key: key);

  @override
  _SchoolAttendanceState createState() => _SchoolAttendanceState();
}

class _SchoolAttendanceState extends State<SchoolAttendance> {
  bool loading = false;
  List<dynamic> classList = [];
  List<dynamic> subjectList = [];
  List<dynamic> classListResult = [];
  String? _selectedOption;

  String? _selectedSubject;
  bool isSelectClass = false;
  bool isClickAttendanceButton = false;
  bool isattendancestatus = false;
  bool hideinputField = true;
  List<Map<String, dynamic>> attendanceList = [];
// Define a ScrollController
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  bool classIsselect = false;
  List<dynamic> section = [];
  String? _section;

  Future<void> fetchData() async {
    await fetchClasses();
    await fetchSubjects();
    setState(() {
      loading = true;
    });
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

  String capitalize(String input) {
    return input.isNotEmpty
        ? input[0].toUpperCase() + input.substring(1)
        : input;
  }

  Future<void> fetchSubjects() async {
    try {
      String school_id = await getSchoolId();
      Response response = await dio.get(
          'http://192.168.1.80:5000/api/teacher/$school_id/$_selectedOption');

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

  fetchSection() async {
    String schoolId = await getSchoolId();
    if (_selectedOption != null && classIsselect) {
      final response = await dio.get(
          "http://192.168.1.80:5000/api/admin/$schoolId/$_selectedOption/section");

      if (response.statusCode == 200) {
        setState(() {
          section = response.data['data'];
          print(section);
        });
      } else {
        showToast("Error");
      }
    }
  }

  final double itemHeight = 100.0; // Example item height, adjust as needed

  Future<void> takeAttendance() async {
    try {
      if (_selectedOption != null &&
          _selectedSubject != null &&
          _section != null) {
        String schoolid = await getSchoolId();
        Response response = await dio.get(
            'http://192.168.1.80:5000/api/teacher/$schoolid/$_selectedOption/$_section/students');

        if (response.statusCode == 200) {
          setState(() {
            classListResult = response.data['data'];
            isClickAttendanceButton = true;
            hideinputField = false;
          });
          showToast('${response.data['message']}');
        } else {
          showToast('${response.data['message']}');
        }
      }
    } catch (e) {
      showToast("$e");
      print("$e");
    }
  }

  void takeAttendances(
      int index, int school_id, int student_id, bool isPresent) {
    bool isStudentPresent =
        attendanceList.any((entry) => entry['student_id'] == student_id);

    if (!isStudentPresent) {
      Map<String, dynamic> attendanceEntry = {
        'school_id': school_id,
        'student_id': student_id,
        'isPresent': isPresent,
      };

      setState(() {
        isattendancestatus = true;
        classListResult[index]['isPresent'] = isPresent;
        classListResult[index]['isAttendanceStatus'] = true;
      });

      attendanceList.add(attendanceEntry);
    } else {
      showToast("Attendance for student with ID $student_id already recorded");
    }
  }

  Future<void> sendAttendanceToDatabase(
      String studentId, bool isPresent) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? teacherId = prefs.getInt('id');

      if (teacherId != null) {
        Map<String, dynamic> data = {
          'class_id': _selectedOption,
          'subject_name': _selectedSubject,
          'teacher_id': teacherId,
          'student_id': studentId,
          'present': isPresent,
        };
        Dio dio = Dio();

        Response response = await dio
            .post('http://192.168.1.80:5000/api/mark-attendance', data: data);
        if (response.statusCode == 200) {
          showToast('${response.data['message']}');
        } else {
          showToast('${response.data['message']}');
        }
      }
    } catch (e) {
      showToast("$e");
      print("$e");
    }
  }

  Widget buildClassDropdown() {
    return hideinputField
        ? Padding(
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
                      isSelectClass = true;
                      classIsselect = true;
                      fetchSection();
                    });
                  }
                },
                items: classList.map((classes) {
                  String? classId =
                      classes['class_id']?.toString(); // Check for null
                  String item = classes['class_name'] ?? ""; // Check for null
                  return DropdownMenuItem<String>(
                    value: classId,
                    child: Text(capitalize(item)),
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
          )
        : Container();
  }

  Widget buildSectionDropDown() {
    return hideinputField
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonFormField<String>(
                value: _section,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _section = newValue;
                    });
                  }
                },
                items: section.map((sectionItem) {
                  String sectionName = sectionItem['name'];
                  String sectionId = sectionItem['section_id'].toString();

                  return DropdownMenuItem<String>(
                    value: sectionId,
                    child: Text(sectionName),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: "Select Section List",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a Section";
                  }
                  return null;
                },
              ),
            ),
          )
        : Container();
  }

  Widget buildSubjectDropdown() {
    return hideinputField
        ? Padding(
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
                    child: Text(capitalize(item)),
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
          )
        : Container();
  }

  Widget buildTakeAttendanceButton() {
    return hideinputField
        ? Center(
            child: Column(
              children: [
                if (_selectedOption != null && _selectedSubject != null)
                  ElevatedButton(
                    onPressed: () async {
                      await takeAttendance();
                    },
                    child: Text("Take Attendance"),
                  )
                else
                  Column(
                    children: [
                      Text("Please Select Class and Subject"),
                    ],
                  ),
              ],
            ),
          )
        : Container();
  }

  Widget buildAttendanceList() {
    return isClickAttendanceButton
        ? classListResult.isEmpty
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: classListResult.length,
                      itemBuilder: (context, index) {
                        final student = classListResult[index];
                        bool isAttendanceStatus =
                            student['isAttendanceStatus'] ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Center(
                            child: Card(
                              color: isAttendanceStatus
                                  ? Color.fromARGB(255, 183, 181, 181)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Name: ${capitalize(student['name'])}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "Roll NO: ${student['student_id']}"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Address: ${student['address']}"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              Future.delayed(
                                                  Duration(milliseconds: 200),
                                                  () {
                                                _scrollController.animateTo(
                                                  (index + 1) * itemHeight,
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeIn,
                                                );
                                              });
                                            });
                                            takeAttendances(
                                                index,
                                                student['school_id'],
                                                student['student_id'],
                                                false);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.red),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                          ),
                                          child: Text("Absent"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              Future.delayed(
                                                  Duration(milliseconds: 200),
                                                  () {
                                                _scrollController.animateTo(
                                                  (index + 1) * itemHeight,
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeIn,
                                                );
                                              });
                                            });
                                            takeAttendances(
                                                index,
                                                student['school_id'],
                                                student['student_id'],
                                                true);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                          ),
                                          child: Text("Present"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
        : Container();
  }

  void SaveAttendenceData() async {
    try {
      String school_id = await getSchoolId();
      String teacher_id = await getId();

      Response response = await dio.post(
          'http://192.168.1.80:5000/api/teacher/attendance/$school_id/$_selectedOption/$teacher_id/$_selectedSubject',
          data: attendanceList);
      if (response.statusCode == 200) {
        showToast("${response.data['message']}");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePage("teacher")));
      } else {
        showToast("${response.data['message']}");
      }
    } catch (e) {
      print(e);
      showToast("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "School Attendance",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF580778),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        child: loading
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    buildClassDropdown(),
                    buildSectionDropDown(),
                    buildSubjectDropdown(),
                    buildTakeAttendanceButton(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: buildAttendanceList(),
                    )
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: isattendancestatus
          ? FloatingActionButton(
              onPressed: SaveAttendenceData,
              child: const Icon(Icons.save),
            )
          : null,
    );
  }
}
