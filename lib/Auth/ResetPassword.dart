import 'package:attendance/Methods/showMessage.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ResetPasswordButton() async {
    try {
      if (_formKey.currentState!.validate()) {
        String password = _passwordController.text.trim();
        String confirmPassword = _confirmPasswordController.text.trim();
        if (password == confirmPassword) {
          Map<String, dynamic> data = {
            "password": password,
            "confirmpassword": confirmPassword
          };
        } else {
          showToast("Password and Confirm Password are not same");
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RESET  PASSWORD"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ResetPasswordButton();
        },
        backgroundColor:
            const Color.fromARGB(255, 187, 33, 243), // Background color
        foregroundColor: Colors.white, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        child: Row(
          children: [],
        ),
      ),
      body: Center(
          child: Column(
        children: [
          Text(
            'Reset Your',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          Text(
            'Password ?',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          Form(
              key: _formKey,
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
                                borderRadius: BorderRadius.circular(10))),
                        validator: (value) {
                          // Phone number validation logic goes here
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          if (value.length < 4) {
                            return 'Password must be at least 4 characters long';
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
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                            hintText: "Confirm Password",
                            label: Text("Comfirm Passwod"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                        validator: (value) {
                          // Phone number validation logic goes here
                          if (value == null || value.isEmpty) {
                            return 'Please enter a  password';
                          }
                          if (value.length < 4) {
                            return 'Password must be at least 4 characters long';
                          }

                          return null;
                        },
                      ),
                    ),
                  )
                ],
              ))
        ],
      )),
    );
  }
}
