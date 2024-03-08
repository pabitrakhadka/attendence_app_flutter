// ignore_for_file: prefer_const_constructors

import 'package:attendance/Auth/AdminLogin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({Key? key}) : super(key: key);

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  List<dynamic> classes = [];
  String? _selectedOption;

  Future<void> fetchClasses() async {
    Dio dio = Dio();
    final response = await dio.get("http://192.168.1.80:5000/api/classes");

    if (response.statusCode == 200) {
      setState(() {
        classes = response.data['data'];
        showSimpleSnackBar(context, "${response.data}");
      });
    } else {
      showSimpleSnackBar(context, "Failed to load classes");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildRegularAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
                alignment: Alignment.center,
                height: 100,
                width: double.infinity,
                color: Color.fromARGB(255, 55, 51, 83),
                child: Row(
                  children: [
                    // Padding(
                    //   padding: EdgeInsets.all(8.0),
                    //   child: DecoratedBox(
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     child: DropdownButtonFormField<String>(
                    //       value: _selectedOption,
                    //       onChanged: (String? newValue) {
                    //         if (newValue != null) {
                    //           setState(() {
                    //             _selectedOption = newValue;
                    //           });
                    //         }
                    //       },
                    //       items: classes.map((classes) {
                    //         String item = classes['class_name'];
                    //         return DropdownMenuItem<String>(
                    //           value: item, // Assign course name as the value
                    //           child: Text(item),
                    //         );
                    //       }).toList(),
                    //       decoration: InputDecoration(
                    //         hintText: "Select Class List",
                    //         border: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //       ),
                    //       validator: (value) {
                    //         if (value == null || value.isEmpty) {
                    //           return "Please select a Class";
                    //         }
                    //         return null;
                    //       },
                    //     ),
                    //   ),
                    // ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  AppBar _buildRegularAppBar() {
    return AppBar(
      title: Text(
        'Summary Report',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }
}
