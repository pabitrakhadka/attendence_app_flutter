// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, use_build_context_synchronously

import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/Auth/db.dart';
import 'package:attendance/Methods/getTokenData.dart';
import 'package:attendance/Methods/showMessage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class TeacherList extends StatefulWidget {
  const TeacherList({super.key});

  @override
  State<TeacherList> createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> {
  String capitilize(String input) {
    if (input.isEmpty) {
      return "";
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  List<dynamic> teachers = []; // Store fetched admins

  Future<void> fetchTeacher() async {
    try {
      String schoolId = await getId();

      final response =
          await dio.get("http://192.168.1.80:5000/api/admin/teacher/$schoolId");

      if (response.statusCode == 200) {
        setState(() {
          teachers = response.data['data'];
        });
      } else {
        showSimpleSnackBar(context, "${response.data['message']}");
        print('Failed to load users');
      }
    } catch (e) {}
  }

  void showDeleteOption(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  String idSchool = await getId();
                  Response response = await dio.delete(
                      'http://192.168.1.80:5000/api/admin/teacher/$idSchool/$id');
                  if (response.statusCode == 200) {
                    showSimpleSnackBar(context, response.data['message']);
                  } else {
                    showSimpleSnackBar(context, "Failed to delete");
                  }
                } catch (e) {
                  showSimpleSnackBar(context, "Failed to delete: $e");
                }

                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTeacher(); // Fetch users when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Teacher List",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF580778),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddTeacher(
                        id: 0,
                      )));
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> teacher =
              teachers[index]; // Get admin data at index
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/pabitra.jpg'),
              ),
              title: Text(
                "${capitilize("${teacher['name']}")}"
                '', // Assuming 'name' field exists
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teacher['email'] ?? ''), // Assuming 'email' field exists
                  Text(teacher['phone'] ?? ''), // Assuming 'phone' field exists
                  Text(teacher['address'] ??
                      ''), // Assuming 'address' field exists
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddTeacher(id: teacher['teacher_id'])));
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      showDeleteOption(context, teacher['teacher_id']);
                      //showDeleteOption(context, teacher['teacher_id']);
                    },
                    child: Icon(Icons.delete),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddTeacher extends StatefulWidget {
  const AddTeacher({required this.id});
  final int id;

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  final GlobalKey<FormState> _formKeyTeacherTeacher = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _courseController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String url = '';
  Future<void> addTecherButton() async {
    try {
      if (_formKeyTeacherTeacher.currentState!.validate()) {
        String name = _nameController.text.trim();
        String address = _addressController.text.trim();
        String phone = _phoneController.text.trim();
        String email = _emailController.text.trim();
        String course = _courseController.text.trim();
        String username = _usernameController.text.trim();
        String password = _passwordController.text.trim();
        String schoolId = await getId();

        Map<String, dynamic> data = {
          'name': name,
          'address': address,
          'phone': phone,
          'email': email,
          'course': course,
          'username': username,
          "password": password
        };
        if (widget.id != 0) {
          url =
              "http://192.168.1.80:5000/api/admin/teacher/$schoolId/${widget.id}";
        } else {
          url = "http://192.168.1.80:5000/api/admin/teacher/$schoolId";
        }
        Response response = await dio.post(url, data: data);
        if (response.statusCode == 200) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => TeacherList()));
        } else {
          showSimpleSnackBar(context, "Error");
        }
      }
    } catch (e) {
      print("Error $e");
      showSimpleSnackBar(context, "$e");
    }
  }

  List<Map<String, dynamic>> teacherData = [];

  fetchTeachers(int id) async {
    try {
      String schoolId = await getId();
      // Assuming this function retrieves the school ID
      Response response = await dio
          .get("http://192.168.1.80:5000/api/admin/teacher/$schoolId/$id");
      if (response.statusCode == 200) {
        if (response.data['data'] != null && response.data['data'].isNotEmpty) {
          print("data ${response.data['data']}");
          Map<String, dynamic> firstTeacherData = response.data['data'][0];
          String name = firstTeacherData['name'];
          String address = firstTeacherData['address'];
          String phone = firstTeacherData['phone'];
          String email = firstTeacherData['email'];
          String course = firstTeacherData['course'];
          String username = firstTeacherData['username'];
          setState(() {
            _nameController.text = name;
            _addressController.text = address;
            _phoneController.text = phone;
            _emailController.text = email;
            _courseController.text = course;
            _usernameController.text = username;
          });
        } else {
          showToast("No teacher data found");
        }
      } else {
        showToast("${response.data['message']}");
      }
    } catch (e) {
      showToast("Error: $e");
      print("Error: $e");
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    if (widget.id != 0) {
      print("id=${widget.id}");
      fetchTeachers(widget.id);
    }
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _courseController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _courseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Teacher"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKeyTeacherTeacher,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hoverColor: Colors.white,
                        focusColor: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Username";
                      } else if (value.length < 3) {
                        return "Minimum 3 characters required";
                      } else {
                        return null;
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                        hintText: "Enter Address ",
                        label: Text("Address"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Address";
                      } else if (value.length < 3) {
                        return "Minimum 3 characters required";
                      } else {
                        return null;
                      }
                    }),
              ),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                        hintText: "Enter Phone Number",
                        label: Text("Phone"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: "Enter Email  ",
                        label: Text("Email"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(
                              r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                      controller: _courseController,
                      decoration: InputDecoration(
                          hintText: "Enter Course  ",
                          label: Text("Course"),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Enter Course";
                        } else if (value.length < 3) {
                          return "Minimum 3 characters required";
                        } else {
                          return null;
                        }
                      })),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                          hintText: "Enter Username  ",
                          label: Text("Username"),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Enter Username";
                        } else if (value.length < 3) {
                          return "Minimum 3 characters required";
                        } else {
                          return null;
                        }
                      })),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          hintText: "Enter Password  ",
                          label: Text("Password"),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Enter Password";
                        } else if (value.length < 5) {
                          return "Minimum 5 characters required";
                        } else {
                          return null;
                        }
                      })),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                    onPressed: addTecherButton,
                    child: Text(
                      widget.id != 0 ? "Update" : "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePickerButton extends StatefulWidget {
  @override
  _ImagePickerButtonState createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.file(
                    _image!,
                    height: 200,
                  )
                : Text('No image selected'),
          ],
        ),
      ),
    );
  }
}
