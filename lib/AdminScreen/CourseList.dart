// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/Auth/db.dart';
import 'package:attendance/Methods/getTokenData.dart';
import 'package:attendance/Methods/showMessage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CourseList extends StatefulWidget {
  const CourseList({super.key});

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  String capitalizeWords(String input) {
    return input.toUpperCase();
  }

  void deleteCourse(int course_id) async {
    try {
      String schoolId = await getId();

      Response response = await dio.delete(
          'http://192.168.1.80:5000/api/admin/course/$schoolId/$course_id');
      if (response.statusCode == 200) {
        showSimpleSnackBar(context, "${response.data['message']}");
      }
    } catch (e) {
      print(e);
      showSimpleSnackBar(context, "${e}");
    }
  }

  bool? loading = false;
  Future fetchCourse() async {
    try {
      String schoolId = await getId();

      Response response =
          await dio.get('http://192.168.1.80:5000/api/admin/course/$schoolId');
      final data = response.data['message'];
      if (response.statusCode == 200) {
        setState(() {
          result = response.data['data'];
          loading = false;
        });
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

  List<dynamic> result = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController _courseController = TextEditingController();

  void submitCourseButton() async {
    try {
      String id = await getId();

      if (_formKey.currentState!.validate()) {
        String courseName = _courseController.text.trim();

        Map<String, dynamic> data = {"course_name": courseName};

        Response response = await dio
            .post('http://192.168.1.80:5000/api/admin/course/$id', data: data);
        if (response.statusCode == 200) {
          showToast("${response.data['message']}");
        } else {
          showToast("${response.data['message']}");
        }
      }
    } catch (e) {
      print(e);
      showSimpleSnackBar(context, "$e");
    }
  }

  void AddCourse(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Course'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _courseController,
              decoration: InputDecoration(
                labelText: "Course name",
                hintText: "Enter Course Name",
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a Course  name';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog on "Close" press
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: submitCourseButton,
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Course List",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF580778),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF580778),
          onPressed: () {
            AddCourse(context);
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: Container(
          child: loading == null
              ? Container(
                  alignment: Alignment
                      .center, // Align content in the center of the container
                  child: Container(
                    width: 50, // Adjust width and height as needed
                    height: 50,
                    decoration: BoxDecoration(
                      // Background color for the container
                      borderRadius: BorderRadius.circular(
                          10), // Optional: Container border radius
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3, // Customize the width of the spinner
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue), // Customize the color of the spinner
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(20.0),
                  child: ListView.builder(
                      itemCount: result.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              "${capitalizeWords(result[index]['course_name'])}",
                              style: TextStyle(
                                color:
                                    Colors.black, // Set your desired text color
                                fontSize: 16.0, // Set your desired font size
                                fontWeight: FontWeight
                                    .bold, // Set your desired font weight
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0), // Set your desired padding
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  color: Colors.green,
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.blue,
                                  onPressed: () {
                                    deleteCourse(result[index]['course_id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
        ));
  }
}
