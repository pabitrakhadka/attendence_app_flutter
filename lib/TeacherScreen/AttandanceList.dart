// ignore_for_file: prefer_const_constructors

import 'package:attendance/Auth/AdminLogin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AttandanceList extends StatefulWidget {
  const AttandanceList({super.key});

  @override
  State<AttandanceList> createState() => _AttandanceListState();
}

class _AttandanceListState extends State<AttandanceList> {
  String? _selectedOption;
  String? _yearOptin;
  String? _semesterOptin;
  List<dynamic> courseList = [];

  final List<String> yearList = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
  ];
  final List<String> semesterList = [
    'First',
    'Second',
    'Third',
    'Fourth',
    'Fifth',
    'Sixth',
    'Seventh',
    'Eighth',
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future fetchCourse() async {
    try {
      Dio dio = Dio();
      Response response = await dio.get('http://192.168.1.80:5000/api/course');
      final data = response.data['message'];
      if (response.statusCode == 200) {
        courseList = response.data['data'];
        print("$courseList");
      } else {
        showSimpleSnackBar(context, "$data");
      }
    } catch (e) {
      showSimpleSnackBar(context, "$e");
      print("$e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCourse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Attandance Mark",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white)),
      body: Form(
        key: _formKey,
        child: Column(
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
                      });
                    }
                  },
                  items: courseList.map((course) {
                    String item = course['course_name'];
                    return DropdownMenuItem<String>(
                      value: item, // Assign course name as the value
                      child: Text(item),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    hintText: "Select Course List",
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
                      });
                    }
                  },
                  items: courseList.map((course) {
                    String item = course['course_name'];
                    return DropdownMenuItem<String>(
                      value: item, // Assign course name as the value
                      child: Text(item),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    hintText: "Select Course List",
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
            Padding(
              padding: EdgeInsets.all(16.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  value: _yearOptin,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _yearOptin = newValue;
                      });
                    }
                  },
                  items: yearList.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    hintText: "Select Year List",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Additional decoration for the dropdown button
                    // Remove the border
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Select Year";
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  value: _semesterOptin,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _semesterOptin = newValue;
                      });
                    }
                  },
                  items: semesterList.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    hintText: "Select Semester List",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Additional decoration for the dropdown button
                    // Remove the border
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Select Semester";
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  value: _semesterOptin,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _semesterOptin = newValue;
                      });
                    }
                  },
                  items: semesterList.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    hintText: "Select Semester List",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Additional decoration for the dropdown button
                    // Remove the border
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Select Subject";
                    }
                    return null;
                  },
                ),
              ),
            )
          ],
        ),
      ),
      
    );
  }
}
