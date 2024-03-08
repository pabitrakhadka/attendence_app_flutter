// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unused_import
import 'package:attendance/Methods/showMessage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// import 'package:attendance/Auth/db.dart';
import 'package:attendance/screens/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:attendance/Auth/Forgot.dart';
import 'package:attendance/screens/Admin.dart';
import 'dart:convert' as convert;
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Methods/capitilize.dart';

class AdminLogin extends StatefulWidget {
  AdminLogin({Key? key}) : super(key: key);

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedOption = 'admin';
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  final storage = FlutterSecureStorage();

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: "${message}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        String username = _usernameController.text.trim();
        String password = _passwordController.text.trim();

        Map<String, dynamic> data = {
          'username': username,
          'password': password,
        };

        Dio dio = Dio();

        Response response = await dio.post(
          "http://192.168.1.80:5000/api/auth/${_selectedOption}/login",
          data: data,
        );

        if (response.statusCode == 200) {
          await secureStorage.write(
              key: 'token', value: response.data['token']);
          await secureStorage.write(
              key: 'id', value: response.data['id'].toString());
          await secureStorage.write(key: 'name', value: response.data['name']);
          await secureStorage.write(
              key: 'school_id', value: response.data['schoolId'].toString());
          await secureStorage.write(key: 'role', value: _selectedOption);
          print("Schhol id=${response.data['schoolId']}");
          //  dio.options.headers['authorization'] =
          //         "Bearer ${response.data['token']}";
          showToast("${response.data['message']}");

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(_selectedOption)));
        } else if (response.statusCode == 401) {
          // Unauthorized, handle accordingly
          print("Unauthorized");
        } else {
          // Handle other status codes
          showToast("Error ");
        }
      }
    } catch (e) {
      print(e);
      showSimpleSnackBar(context, "$e");
    }
  }

  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 246),
      body: Container(
        child: Form(
          key: _formKey,
          child: _loginUi(context),
        ),
      ),
    );
  }

  Widget _loginUi(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF580778),
                      Color(0xFF580778),
                    ]),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100))),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "Student Attandence ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 33,
                          color: Colors.white),
                    ),
                    Text(
                      "Management System",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white),
                    ),
                  ],
                ),
              )
            ]),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(10), // Adjust border radius as needed
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedOption, // Use _selectedOption as value
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedOption = newValue;
                    });
                  }
                },
                items: <String>['superadmin', 'admin', 'teacher']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(Capitalize(value)),
                  );
                }).toList(),
                decoration: InputDecoration(
                  // Additional decoration for the dropdown button
                  border: InputBorder.none, // Remove the border
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                    labelText: "Username",
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
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Enter password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.white, // Set the background color
                  filled: true,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please Enter Password";
                  } else if (value.length < 6) {
                    return "Minimum 6 characters required";
                  } else {
                    return null;
                  }
                }),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(
                    0xFF580778,
                  )),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ForgotAccount(role: _selectedOption)),
                );
              },
              child: Text(
                "Forgot Account?",
                style: TextStyle(
                  color: Color(0xFF580778),
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF580778),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showSimpleSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(
          seconds: 3), // Duration for how long the SnackBar should be displayed
    ),
  );
}
