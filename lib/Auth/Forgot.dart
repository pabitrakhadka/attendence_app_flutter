// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/Auth/db.dart';
import 'package:attendance/Methods/showMessage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ForgotAccount extends StatefulWidget {
  final String role;
  const ForgotAccount({Key? key, required this.role}) : super(key: key);

  @override
  State<ForgotAccount> createState() => _ForgotAccountState();
}

class _ForgotAccountState extends State<ForgotAccount> {
  final GlobalKey<FormState> _formKeys = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool isLoading = false;
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void resetButton(int id) async {
    try {
      if (_formKeys.currentState!.validate()) {
        String password = _passwordController.text.trim();
        String confirmPassword = _confirmPasswordController.text.trim();

        if (password == confirmPassword) {
          Map<String, dynamic> data = {
            "password": password,
          };
          print("data=${data}");
          Response response = await dio.post(
              'http://192.168.1.80:5000/api/auth/${widget.role}/forgotpassword/$id',
              data: data);
          print(response);
          if (response.statusCode == 200) {
            showToast("${response.data['message']}");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AdminLogin()));
          } else {
            showToast("${response.data['message']}");
          }
        } else {
          showToast("Password and Confirm Password are not same");
        }
      }
    } catch (e) {
      print('${e}');
    }
  }

  void _showResetPasswordDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return isLoading
            ? SingleChildScrollView(
                child: AlertDialog(
                  backgroundColor: Color.fromARGB(255, 79, 130, 172),
                  content: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCLWesV1b5wBr_9l8RZq4zNH3MZm1jq8TNvw&usqp=CAU",
                          ),
                        ),
                        Text(
                          'Reset Your',
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                        Text(
                          'Password?',
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                        Form(
                          key: _formKeys,
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      hintText: "Enter Password",
                                      label: Text("Password"),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value.length < 4) {
                                        return 'Password must be at least 4 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextFormField(
                                    controller: _confirmPasswordController,
                                    decoration: InputDecoration(
                                      hintText: "Confirm Password",
                                      label: Text("Confirm Password"),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resetButton(id);
                      },
                      child: Text('Reset Password'),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  children: const [CircularProgressIndicator()],
                ),
              );
      },
    );
  }

  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<void> checkPhone() async {
    try {
      if (_formKey.currentState!.validate()) {
        String phone = _phoneController.text.trim();
        String username = _usernameController.text.trim();

        Map<String, dynamic> data = {
          "username": username,
          'phone': phone,
        };

        String url = 'http://192.168.1.80:5000/api/auth/forgot/${widget.role}';

        Response response = await dio.get(url, data: data);

        if (response.statusCode == 200) {
          Navigator.pop(context);
          showToast("${response.data['message']}");
          _showResetPasswordDialog(response.data['id']);
        } else {
          showToast("${response.data['message']}");
        }
      }
    } catch (e) {
      showToast("$e");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 128, 48, 159),
        appBar: AppBar(
          title: Text("Fotgot Account"),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF580778),
          onPressed: checkPhone,
          child: Text(
            "Send",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Image.network(
                "https://cdn-icons-png.flaticon.com/512/6434/6434880.png",
                height: 150,
                width: 100,
              ),
              Text(
                'Forgot Your',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              Text(
                'Password ?',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              SizedBox(height: 10),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                                hintText: "Enter Username",
                                label: Text("Username"),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            validator: (value) {
                              // Phone number validation logic goes here
                              if (value == null || value.isEmpty) {
                                return 'Please enter a phone number';
                              }

                              if (value.length <= 3) {
                                return 'Please username mim 3 character';
                              }

                              return null; // Return null if the validation passes
                            },
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                                hintText: "Enter Your Phone Number",
                                label: Text("Phone Number"),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            validator: (value) {
                              // Phone number validation logic goes here
                              if (value == null || value.isEmpty) {
                                return 'Please enter a phone number';
                              }

                              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }

                              return null; // Return null if the validation passes
                            },
                          ),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }
}
