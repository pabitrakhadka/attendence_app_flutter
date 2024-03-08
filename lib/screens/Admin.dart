// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  String showMessage = "";
  //insert function
  Future<void> insertRecord() async {
    try {
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => HomePage()));
      if (_formKey.currentState!.validate()) {}

      String companyName = _companyNameController.text;
      String companyRegNo = _companyRegNoController.text;
      String employerName = _employerNameController.text;
      String designational = _designationalController.text;
      String country = _countryController.text;
      String mobileNumber = _mobileNumberController.text;
      String address = _addressController.text;
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => HomePage()));
      print(companyName);
      print("$companyRegNo");
      print("$employerName");
      print("$designational");
      print("$country");
      print("$mobileNumber");
      print("$address");
      String uri = "http://127.0.0.1/attendance_api/insert_record.php";
      var res = await http.post(
        Uri.parse(uri),
        body: {
          "com_name": companyName,
          "com_reg": companyRegNo,
          "emp_name": employerName,
          "designational": designational,
          "country": country,
          "phone_number": mobileNumber,
          "address": address,
        },
      );

      print("HTTP Response: ${res.body}");
      var response = jsonDecode(res.body);

      if (response['success']) {
        showLoginDialog(context);
        print("Record Inserted");
      } else {
        print("Record is not inserted");
      }
    } catch (e) {
      print("Error: $e");
      showMessage = "$e";
    }
  }

// showMessage
  Future<void> showLoginDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Message Box'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(showMessage),
                // You can add more widgets here for login information
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Declare controllers for each TextFormField
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyRegNoController = TextEditingController();
  final TextEditingController _employerNameController = TextEditingController();
  final TextEditingController _designationalController =
      TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RegExp regex = RegExp(r'^\d{10}$');
  // void _submitForm() {
  //   if (_formKey.currentState!.validate()) {
  //     // Access values entered in text fields

  //   }
  // }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _companyNameController.dispose();
    _companyRegNoController.dispose();
    _employerNameController.dispose();
    _designationalController.dispose();
    _countryController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student Attendance Management System",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/admin_icon.png'),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    controller: _companyNameController,
                    decoration: InputDecoration(
                        hintText: "Enter Company Name",
                        label: Text('Company Name'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.1)),
                        prefixIcon: Icon(Icons.location_city)),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter The Company Name';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    controller: _companyRegNoController,
                    decoration: InputDecoration(
                        hintText: "Enter Company Reg no",
                        label: Text('Company Reg  (Optional)'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.1)),
                        prefixIcon: Icon(Icons.book)),
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return "Please Company Reg";
                    //   }
                    //   return null;
                    // },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    controller: _employerNameController,
                    decoration: InputDecoration(
                        hintText: "Enter Employer Name",
                        label: Text('Employer Name'),
                        prefixIcon: Icon(Icons.supervised_user_circle)),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Employer Name";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    controller: _designationalController,
                    decoration: InputDecoration(
                        hintText: "Enter Designational ",
                        label: Text('Designational (Optional)'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.1)),
                        prefixIcon: Icon(Icons.logo_dev)),
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return "Please ";
                    //   }
                    //   return null;
                    // },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    controller: _countryController,
                    decoration: InputDecoration(
                        hintText: "Enter Country ",
                        label: Text('Country (Optional)'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.1)),
                        prefixIcon: Icon(Icons.location_city)),
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return "Please ";
                    //   }
                    //   return null;
                    // },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _mobileNumberController,
                    decoration: InputDecoration(
                        hintText: "Enter Mobile No ",
                        label: Text('Mobile'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.1)),
                        prefixIcon: Icon(Icons.phone)),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter The Mobile Number ";
                      } else if (regex.hasMatch(value)) {
                        return null;
                      } else {
                        return "Please Enter Valid Mobile Number ";
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                        hintText: "Enter Address ",
                        label: Text('Address'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.1)),
                        prefixIcon: Icon(Icons.location_on)),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please ";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: insertRecord,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the radius as needed
                        )),
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


 

// validate phoneNumber
 