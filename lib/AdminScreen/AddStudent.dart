import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/Auth/db.dart';
import 'package:attendance/Methods/getTokenData.dart';
import 'package:attendance/Methods/showMessage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _sectionController;
  late TextEditingController _phoneControler;
  // ignore: non_constant_identifier_names
  late TextEditingController _father_nameController;
  // ignore: non_constant_identifier_names
  late TextEditingController _father_phoneController;
  late TextEditingController _addressController;

  //Add Student Button
  addStudentButon() async {
    try {
      if (_formKey.currentState!.validate()) {
        String name = _nameController.text.trim();

        String phone = _phoneControler.text.trim();
        String fatherName = _father_nameController.text.trim();
        String fatherPhone = _father_phoneController.text.trim();
        String address = _addressController.text.trim();

        String schoolId = await getId();
        Map<String, dynamic> data = {
          "name": name,
          "class_id": _selectedOption,
          "address": address,
          "section_id": _section,
          "phone": phone,
          "father_name": fatherName,
          "father_phone": fatherPhone
        };

        Response response = await dio.post(
            'http://192.168.1.80:5000/api/admin/$schoolId/student',
            data: data);
        if (response.statusCode == 200) {
          showToast("${response.data['message']}");
          Navigator.pop(context);
        } else {
          showToast("${response.data['message']}");
        }
      }
    } catch (e) {
      showToast("Error");
      print(e);
    }
  }

  List<dynamic> classes = [];
  bool classIsselect = false;
  List<dynamic> section = [];

  String? _selectedOption;
  String? _section;

  fetchClasses() async {
    String schoolId = await getId();
    final response =
        await dio.get("http://192.168.1.80:5000/api/admin/$schoolId/class");

    if (response.statusCode == 200) {
      setState(() {
        classes = response.data['data'];
      });
    } else {
      showSimpleSnackBar(context, "Error Fetching Class");
    }
  }

  fetchSection() async {
    String schoolId = await getId();
    if (_selectedOption != null && classIsselect) {
      final response = await dio.get(
          "http://192.168.1.80:5000/api/admin/$schoolId/$_selectedOption/section");

      if (response.statusCode == 200) {
        setState(() {
          section = response.data['data'];
          print("section =${section}");
        });
      } else {
        showSimpleSnackBar(context, "Error Fetching Class");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClasses();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _sectionController = TextEditingController();
    _phoneControler = TextEditingController();
    _father_nameController = TextEditingController();
    _father_phoneController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _sectionController.dispose();
    _phoneControler.dispose();
    _father_nameController.dispose();
    _father_phoneController.dispose();
    _addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Student",
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
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Enter Name",
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Name";
                      } else if (value.length < 3) {
                        return "Minimum 3 characters required";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
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
                            classIsselect = true;
                            fetchSection();
                          });
                        }
                      },
                      items: classes.map((classItem) {
                        String className = classItem['class_name'];
                        String classId = classItem['class_id'].toString();

                        return DropdownMenuItem<String>(
                          value: classId,
                          child: Text(className),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: "Select Class List",
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
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: "Enter Address",
                      labelText: "Address",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Name";
                      } else if (value.length < 3) {
                        return "Minimum 3 characters required";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _section,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _section = newValue;
                          });
                        }
                      },
                      items: section.map((sectionItem) {
                        String sectionName = sectionItem['name'];
                        String sectionId = sectionItem['section_id'].toString();

                        return DropdownMenuItem<String>(
                          value: sectionId,
                          child: Text(sectionName),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: "Select Section List",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a Section";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _phoneControler,
                    decoration: InputDecoration(
                        hintText: "Enter PhoneNumber  ",
                        label: Text("PhoneNumber"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _father_nameController,
                    decoration: InputDecoration(
                        hintText: "Enter Father Name",
                        label: Text("Father"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Father Name";
                      } else if (value.length < 3) {
                        return "Minimum 3 characters required";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _father_phoneController,
                    decoration: InputDecoration(
                        hintText: "Enter Father Phone  ",
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
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF580778)),
                    ),
                    onPressed: addStudentButon,
                    child: Text(
                      "Add Student",
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
