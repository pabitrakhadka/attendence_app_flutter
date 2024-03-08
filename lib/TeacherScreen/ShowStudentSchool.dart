import 'package:attendance/Methods/Scaffold.dart';
import 'package:attendance/Methods/capitilize.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../Auth/db.dart';
import '../Methods/getTokenData.dart';
import '../Methods/showMessage.dart';

// import 'package:flutter_pdfview/flutter_pdfview.dart';

class ShowStudentSchool extends StatelessWidget {
  const ShowStudentSchool({Key? key});

  @override
  Widget build(BuildContext context) {
    return buildScaffold("Student List", FilterTableDemo());
  }
}

class FilterTableDemo extends StatefulWidget {
  @override
  _FilterTableDemoState createState() => _FilterTableDemoState();
}

class _FilterTableDemoState extends State<FilterTableDemo> {
  String? _selectedOption;
  bool loading = false;
  List<dynamic> students = [];
  List<dynamic> classList = []; // Initialize empty list

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    await fetchClasses();
  }

  Future<void> fetchStudentsOfClass(String selectedClass) async {
    try {
      String schoolId = await getSchoolId();
      Response response = await dio.get(
          "http://192.168.1.80:5000/api/teacher/$schoolId/$_selectedOption/students");

      if (response.statusCode == 200) {
        setState(() {
          students = response.data['data'];
        });
      } else {
        showToast('${response.data['message']}');
      }
    } catch (e) {
      showToast("$e");
      print("$e");
    }
  }

  void makePhoneCall(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      print('Error making phone call: $e');
      showToast("Error making phone call");
    }
  }

  Future<void> fetchClasses() async {
    try {
      String schoolId = await getSchoolId();
      Response response =
          await dio.get("http://192.168.1.80:5000/api/teacher/$schoolId/class");

      if (response.statusCode == 200) {
        setState(() {
          loading = true;
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

  @override
  Widget build(BuildContext context) {
    return loading
        ? Column(
            children: [
              Padding(
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

                          fetchStudentsOfClass("${_selectedOption}");
                        });
                      }
                    },
                    items: classList.map((classes) {
                      String item = classes['class_name'];
                      String class_id = classes['class_id'].toString();

                      return DropdownMenuItem<String>(
                        value: class_id,
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
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    // Build list items using students data
                    return Card(
                      child: ListTile(
                        trailing: GestureDetector(
                          onTap: () {
                            makePhoneCall(students[index]['father_phone']);
                          },
                          child: Icon(
                            Icons.phone,
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          "FatherName:${capitalizeEachWord(students[index]['father_name'])}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            "Name: ${capitalizeEachWord(students[index]['name'])}"),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
