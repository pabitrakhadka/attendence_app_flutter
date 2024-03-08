// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last

import 'package:attendance/Auth/AdminLogin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AdminList extends StatefulWidget {
  const AdminList({Key? key});

  @override
  State<AdminList> createState() => _AdminListState();
}

class _AdminListState extends State<AdminList> {
  List<dynamic> admins = []; // Store fetched admins
  bool isvalue = false;
  String capitalize(String input) {
    if (input == null || input.isEmpty) {
      return "";
    }
    return input[0].toUpperCase() + input.substring(1);
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
                Dio dio = Dio();
                try {
                  Response response = await dio
                      .delete('http://192.168.1.80:5000/api/admin/$id');
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

  Future<void> fetchAdmin() async {
    Dio dio = Dio();
    final response =
        await dio.get("http://192.168.1.80:5000/api/superadmin/school");

    if (response.statusCode == 200) {
      admins = response.data['data'];
      setState(() {
        isvalue = true;
      });
    } else {
      // Handle API error (e.g., show error message)
      print('Failed to load users');
    }
  }

  @override
  void initState() {
    super.initState();
    //fetchAdmin(); // Fetch users when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin List"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddAdmin()));
        },
        child: Icon(Icons.add),
      ),
      body: isvalue
          ? ListView.builder(
              itemCount: admins.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> admin =
                    admins[index]; // Get admin data at index
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/school_icon.png'),
                    ),
                    title: Text(
                      'SchoolName:${capitalize(admin['school_name'])}', // Assuming 'name' field exists
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(admin['email'] ??
                            ''), // Assuming 'email' field exists
                        Text(admin['phone'] ??
                            ''), // Assuming 'phone' field exists
                        Text(admin['school_address'] ??
                            ''), // Assuming 'address' field exists
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Declare isedit outside the callback
                            String isedit = "true";
                            // Do something with isedit if needed
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            showDeleteOption(context, admin['admin_id']);
                          },
                          child: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
    );
  }
}

class AddAdmin extends StatefulWidget {
  @override
  State<AddAdmin> createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  late TextEditingController _schoolName;
  late TextEditingController _schoolAddress;
  late TextEditingController _addressController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _schoolName = TextEditingController();
    _schoolAddress = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose existing controllers
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _schoolAddress.dispose();
    _schoolName.dispose();
    _addressController.dispose();

    super.dispose();
  }

  void addAdminButton() async {
    try {
      // Validate the form using the form key
      if (_formKey.currentState!.validate()) {
        // Extract data from text controllers
        String schoolName = _schoolName.text.trim();
        String schoolAddress = _schoolAddress.text.trim();
        String email = _emailController.text.trim();
        String phone = _phoneController.text.trim();
        String username = _usernameController.text.trim();
        String password = _passwordController.text.trim();

        // Prepare data for the API request
        Map<String, dynamic> data = {
          "schoolName": schoolName,
          'schoolAddress': schoolAddress,
          'email': email,
          'phone': phone,
          'username': username,
          'password': password,
        };

        // Print data for debugging
        print("data=$data");

        // Create Dio instance
        Dio dio = Dio();

        // // Make a POST request to the API
        Response response = await dio.post(
            "http://192.168.1.80:5000/api/superadmin/add/school",
            data: data);

        // // Check the HTTP status code of the response
        if (response.statusCode == 200) {
          //   // Show a success Snackbar if the request is successful
          showSimpleSnackBar(context, response.data['message']);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AdminList()));
        } else if (response.statusCode == 400) {
          //   // Parse validation errors from the response and display to the user
          String errorMessage = response.data['error'];
          //   showSimpleSnackBar(context, "Validation Error: $errorMessage");
        } else {
          //   // Log the response details and show an error Snackbar
          print(response);
          showSimpleSnackBar(context, "Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      // Log and display any caught exceptions
      print("Error: $e");
      showSimpleSnackBar(context, "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Admin",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF580778),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                      controller: _schoolName,
                      decoration: InputDecoration(
                        hintText: "Enter School Name",
                        label: Text("School Name"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter School Name";
                        } else if (value.length < 3) {
                          return "Minimum 3 characters required";
                        } else {
                          return null;
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: "Enter Email",
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                        hintText: "Enter PhoneNumber  ",
                        label: Text("PhoneNumber"),
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _schoolAddress,
                    decoration: InputDecoration(
                        hintText: "Enter School Address  ",
                        label: Text("Address"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Address";
                      } else if (value.length < 3) {
                        return "Minimum 4 characters required";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                          hintText: "Enter School UserName",
                          label: Text("School Username"),
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
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          hintText: "Enter Password ",
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
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addAdminButton,
                        child: Text(
                          "Submit",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                          Color(0xFF580778),
                        )),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to show a simple SnackBar
  void showSimpleSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
