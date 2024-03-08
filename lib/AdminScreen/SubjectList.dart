import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/Auth/db.dart';
import 'package:attendance/Methods/capitilize.dart';
import 'package:attendance/Methods/getTokenData.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SubjectList extends StatefulWidget {
  const SubjectList({super.key});

  @override
  State<SubjectList> createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectList> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _bcaFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _nebFormKey = GlobalKey<FormState>();
  String? _selectedOption;
  String? _selectedClass;
  String? _yearOptin;
  String? _semesterOptin;
  late TextEditingController _subjectsController;
  List<dynamic> result = [];
  List<dynamic> classList = [];

  addSubjectButon() async {
    try {
      String schooId = await getId();
      String? class_name = _selectedClass;
      String? level = _selectedOption;
      String subject_name = _subjectsController.text.trim();
      Map<String, dynamic> data = {
        'subject_name': subject_name,
        'level': level,
      };

      Response response = await dio.post(
          'http://192.168.1.80:5000/api/admin/$schooId/$class_name/subject',
          data: data);

      if (response.statusCode == 200) {
        showSimpleSnackBar(context, "${response.data['message']}");
      } else {
        showSimpleSnackBar(context, "${response.data['message']}");
      }
    } catch (e) {
      showSimpleSnackBar(context, "$e");
    }
  }

  fetchCourse() async {
    try {
      String schoolid = await getId();
      Response response =
          await dio.get('http://192.168.1.80:5000/api/admin/course/$schoolid');
      if (response.statusCode == 200) {
        result = response.data['data'];
        setState(() {
          loading = true;
        });
      }
    } catch (e) {
      showSimpleSnackBar(context, "$e");
    }
  }

  fetchClasses() async {
    String schoolId = await getId();
    final response =
        await dio.get("http://192.168.1.80:5000/api/admin/$schoolId/class");

    if (response.statusCode == 200) {
      classList = response.data['data'];
    } else {
      print('Failed to load classes');
    }
  }

  bool loading = false;
  @override
  void initState() {
    super.initState();
    _subjectsController = TextEditingController();
    fetchData();
  }

  fetchData() async {
    await fetchCourse();
    await fetchClasses();
  }

  @override
  void dispose() {
    super.dispose();
    _subjectsController.dispose();
  }

  final List<String> yearList = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
  ];
  final List<String> semesterList = [
    'First',
    'Second',
    'Third',
    'Fourth',
    'Fifth',
    'Sixth',
    'Seventh',
    'Eighth',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Subject Lsit/Add",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF580778),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              loading
                  ? Padding(
                      padding: EdgeInsets.all(10.0),
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
                              });
                            }
                          },
                          items: result.map((course) {
                            String item = toUppercase(course['course_name']);
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            hintText: "Select Course List",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            // Additional decoration for the dropdown button
                            // Remove the border
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a Class";
                            }
                            return null;
                          },
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
              if (_selectedOption == 'BBS') ...{
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _yearOptin,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _yearOptin = newValue;
                          });
                        }
                      },
                      items: yearList.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: "Select Year List",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // Additional decoration for the dropdown button
                        // Remove the border
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Select Year";
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                _selectedOption == "BCA"
                    ? Padding(
                        padding: EdgeInsets.all(10.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _semesterOptin,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _semesterOptin = newValue;
                                });
                              }
                            },
                            items: semesterList.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              hintText: "Select Semester List",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // Additional decoration for the dropdown button
                              // Remove the border
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Select Semester";
                              }
                              return null;
                            },
                          ),
                        ),
                      )
                    : Text(
                        'Comming Soon',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                // Additional widgets for BCA
              } else if (_selectedOption == 'BBS') ...{
                // Code specific to BBS

                // Additional widgets for BBS
              } else if (_selectedOption == "SCHOOL") ...{
                Column(
                  children: [
                    Form(
                      key: _nebFormKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                                controller: _subjectsController,
                                decoration: InputDecoration(
                                  labelText: "Enter Subjects",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fillColor:
                                      Colors.white, // Set the background color
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
                            padding: const EdgeInsets.all(10.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedClass,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedClass = newValue;
                                    });
                                  }
                                },
                                items: classList.map((classs) {
                                  String item = classs['class_name'];
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  hintText: "Select Class List",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  // Additional decoration for the dropdown button
                                  // Remove the border
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
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: addSubjectButon,
                      child: Text(
                        "Add",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Color(
                            0xFF580778)), // Change the color to your desired color
                      ),
                    )
                  ],
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}
