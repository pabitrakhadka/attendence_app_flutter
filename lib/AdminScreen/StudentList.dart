import 'package:attendance/AdminScreen/addStudent.dart';
import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/Auth/db.dart';
import 'package:attendance/Methods/getTokenData.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  late TextEditingController _nameController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<dynamic> classes = [];
  List<dynamic> results = [];
  String? _selectedOption;

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  // ignore: non_constant_identifier_names
  Future<String> getSchoolId() async {
    // Replace 'school_id' with the key you used to store the ID in secure storage
    String? schoolId = await secureStorage.read(key: 'school_id') ?? '';
    return schoolId;
  }

  fetchClasses() async {
    String schoolId = await getId();
    final response =
        await dio.get("http://192.168.1.80:5000/api/admin/$schoolId/class");

    if (response.statusCode == 200) {
      classes = response.data['data'];
    } else {
      showSimpleSnackBar(context, "Error Fetching Class");
    }
  }

  final List<String> items = List.generate(50, (index) => 'Item ${index + 1}');
  List<String> filteredItems = [];

//search student function
  searchStudent() async {
    try {
      if (_formKey.currentState!.validate()) {
        String name = _nameController.text;

        Map<String, dynamic> data = {
          "name": name,
          "class_id": _selectedOption,
          "section_id": _section
        };
        String adminId = await getId();

        Response response = await dio.get(
            'http://192.168.1.80:5000/api/admin/$adminId/search',
            data: data);
        if (response.statusCode == 200) {
          setState(() {
            results = response.data['data'];
          });
        }
      }
    } catch (e) {
      showSimpleSnackBar(context, "$e");
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    fetchClasses();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  bool classIsselect = false;
  List<dynamic> section = [];
  fetchSection() async {
    String schoolId = await getId();
    if (_selectedOption != null && classIsselect) {
      final response = await dio.get(
          "http://192.168.1.80:5000/api/admin/$schoolId/$_selectedOption/section");

      if (response.statusCode == 200) {
        setState(() {
          section = response.data['data'];
          print("section =$section");
        });
      } else {
        showSimpleSnackBar(context, "Error Fetching Class");
      }
    }
  }

  String? _section;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student List",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF580778),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddStudent()));
        },
        child: Icon(Icons.add),
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
                        String classID = classItem['class_id'].toString();

                        return DropdownMenuItem<String>(
                          value: classID,
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
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: searchStudent,
                    child: Column(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            toSentenceCase(results[index]
                                ['name']), // Assuming 'name' field exists
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "RollNo: ${results[index]['student_id']}",
                              ),
                              Text(
                                toSentenceCase(
                                    "Address: ${results[index]['address']}"),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             AddAdmin(admin['idmin_id'])));
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  // showDeleteOption(
                                  //     context, teacher['teacher_id']);
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String toSentenceCase(String input) {
  if (input == null || input.isEmpty) {
    return '';
  }

  return input.toLowerCase().split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1);
    }
    return '';
  }).join(' ');
}
