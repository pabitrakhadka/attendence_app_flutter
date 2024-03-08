// Ignore the `ignore_for_file` comment as it doesn't affect the code functionality.

// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, avoid_print, non_constant_identifier_names

import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/Auth/db.dart';
import 'package:attendance/Methods/getTokenData.dart';
import 'package:attendance/Methods/showMessage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClassList extends StatefulWidget {
  const ClassList({Key? key}) : super(key: key);

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  bool loder = false;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  // ignore: non_constant_identifier_names
  Future<String> getSchoolId() async {
    // Replace 'school_id' with the key you used to store the ID in secure storage
    String? schoolId = await secureStorage.read(key: 'school_id') ?? '';
    return schoolId;
  }

  final _formKey = GlobalKey<FormState>();
  final _formKeys = GlobalKey<FormState>();

  TextEditingController _classNameController = TextEditingController();
  TextEditingController _sectionNameController = TextEditingController();

  List<dynamic> classes = [];

  @override
  void initState() {
    super.initState();
    fetchClasses();
    print("fetch clas is call");
  }

  @override
  void dispose() {
    super.dispose();
    _classNameController.dispose();
  }

  fetchClasses() async {
    String schoolId = await getId();
    final response =
        await dio.get("http://192.168.1.80:5000/api/admin/$schoolId/class");

    if (response.statusCode == 200) {
      setState(() {
        classes = response.data['data'];
        setState(() {
          loder = true;
        });
      });
    } else {
      print('Failed to load classes');
    }
  }

  void addClassData(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Class'),
          content: Form(
            key: _formKey, // Associate form key with the dialog's Form
            child: TextFormField(
              controller: _classNameController,
              decoration: InputDecoration(
                labelText: "Class Name",
                hintText: "Enter Class Name",
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a class name';
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
              onPressed: submitClassNameButton,
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void submitClassNameButton() async {
    try {
      if (_formKey.currentState!.validate()) {
        String className = _classNameController.text;
        className = className.trim();
        className = className.replaceAll(' ', '');
        String schoolId = await getId();
        Map<String, dynamic> data = {
          "school_id": schoolId,
          "class_name": className
        };

        Response response = await dio.post(
            "http://192.168.1.80:5000/api/admin/class/$schoolId",
            data: data);

        if (response.statusCode == 200) {
          showSimpleSnackBar(context, response.data['message']);
        } else {
          showSimpleSnackBar(context, response.data['message']);
        }
      }
    } catch (e) {
      showSimpleSnackBar(context, "$e");
      print("$e");
    }
  }

  void AddSection(BuildContext context, int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Section'),
          content: Form(
            key: _formKeys,
            child: TextFormField(
              controller: _sectionNameController,
              decoration: InputDecoration(
                labelText: "Class Name",
                hintText: "Enter Class Name",
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a class name';
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
              onPressed: () {
                addSectionButon(id);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  addSectionButon(int id) async {
    try {
      if (_formKeys.currentState!.validate()) {
        String sectionName = _sectionNameController.text.trim();

        if (sectionName.length >= 3) {
          String schoolId = await getId();
          Map<String, dynamic> data = {"section_name": sectionName};

          Response response = await dio.post(
              "http://192.168.1.80:5000/api/admin/section/$schoolId/$id",
              data: data);

          if (response.statusCode == 200) {
            showSimpleSnackBar(context, response.data['message']);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ClassList()));
          } else {
            showSimpleSnackBar(context, response.data['message']);
          }
        } else {
          showToast("Section Name is not valid !");
        }
      }
    } catch (e) {
      showSimpleSnackBar(context, "$e");
      print("$e");
    }
  }

  deleteClass(int id) async {
    try {
      String idSchool = await getId();
      print("function is cll =${id}");
      Response response = await dio
          .delete('http://192.168.1.80:5000/api/admin/class/$idSchool/$id');
      if (response.statusCode == 200) {
        setState(() {
          showToast(response.data['message']);
        });
      } else {
        // If the response doesn't contain data in JSON format, handle it accordingly
        showToast(
            "${response.data['message']}"); // Or provide a default message
      }
    } catch (e) {
      showSimpleSnackBar(context, "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Class List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF580778),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addClassData(context);
        },
        child: Icon(Icons.add),
      ),
      body: loder
          ? ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> classs = classes[index];
                return GestureDetector(
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                        onLongPress: () {
                          deleteClass(classs['class_id']);
                        },
                        title: Text(classs['class_name']),
                        trailing: ElevatedButton(
                          onPressed: () {
                            AddSection(context, classs['class_id']);
                          },
                          child: Text("Add Section"),
                        )
                        // Other properties or widgets for each item if needed
                        ),
                  ),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(
                strokeWidth: 3, // Customize the width of the spinner
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue), // Customize the color of the spinner
              ),
            ),
    );
  }
}
