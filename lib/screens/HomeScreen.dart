// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously

//import 'package:attendance/AdminScreen/AssignTeacher.dart';
import 'package:attendance/AdminScreen/ClassList.dart';
import 'package:attendance/AdminScreen/CourseList.dart';
import 'package:attendance/AdminScreen/StudentList.dart';
import 'package:attendance/AdminScreen/SubjectList.dart';
import 'package:attendance/AdminScreen/TeacherList.dart';
import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/Auth/db.dart';
import 'package:attendance/Methods/NavigatePage.dart';
import 'package:attendance/Methods/showMessage.dart';
import 'package:attendance/Methods/getTokenData.dart';
import 'package:attendance/SuperScren/AdminList.dart';
import 'package:attendance/TeacherScreen/AttandanceList.dart';
import 'package:attendance/TeacherScreen/MonthlyReport.dart';
import 'package:attendance/TeacherScreen/SeeReport.dart';
import 'package:attendance/TeacherScreen/ShowStudentSchool.dart';

import 'package:attendance/TeacherScreen/SchoolAtten.dart';
import 'package:attendance/TeacherScreen/WeekelyReport.dart';
// import 'package:attendance/TeacherScreen/ShowStudentSchool.dart';
import 'package:attendance/screens/AttandanceReport.dart';
import 'package:attendance/screens/DrawerScreen.dart';
import 'package:attendance/screens/SummaryReport.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  // const HomePage({super.key});
  final String role;

  // Constructor with role parameter
  const HomePage(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    // Replace this with the user's role

    Widget buildContentBasedOnRole(String role) {
      switch (role) {
        case 'admin':
          return AdminScreen(); // Replace AdminScreen with your admin view
        case 'superadmin':
          return SuperAdminScreen(); // Replace SuperAdminScreen with your super admin view
        case 'teacher':
          return TeacherScreen(); // Replace TeacherScreen with your teacher view
        default:
          return UnknownRoleScreen(); // Replace UnknownRoleScreen with a default view for unknown roles
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Student Attendance Management System",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          backgroundColor: Color(0xFF580778),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        // drawer: DrawerScreen(role: role),
        body: buildContentBasedOnRole(role));
  }
}

// super addmin role
class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  List<Map<String, dynamic>> superadminData = [];
  String errorMessage = "";
  Future<void> clearStoredValues() async {
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'id');
    await secureStorage.delete(key: 'name');
  }

  loadData() async {
    await fetchTotalSchool();
    await fetchAdmin();
    await getSuperAdminDetails();
  }

  getSuperAdminDetails() async {
    try {
      String id = await getId();
      print("id ${id}");
      Response response =
          await dio.get('http://192.168.1.80:5000/api/superadmin/$id/profile');
      if (response.statusCode == 200) {
        superadminData = response.data['profile'];
        print("Super admi data$superadminData}");
      } else {
        errorMessage = "${response.data['message']}";
      }
    } catch (e) {
      errorMessage = "Error Fetching ..";
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
    print("load data is called");
  }

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
                try {
                  Response response = await dio
                      .delete('http://192.168.1.80:5000/api/super/$id');
                  if (response.statusCode == 200) {
                    showToast("${response.data['message']}", isSuccess: true);
                  } else {
                    showToast("${response.data['message']}", isSuccess: false);
                  }
                } catch (e) {
                  showToast("message", isSuccess: false);
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

  fetchTotalSchool() async {
    try {
      String token = await getToken();

      Response response = await dio.get(
        'http://192.168.1.80:5000/api/superadmin/totalschool',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          loader = true;
        });

        cardList.add({
          "title": response.data["title"].toString(),
          "content": response.data["totalSchool"].toString(),
        });
        print("data : ${response.data}");
        print("je");
      }
    } catch (e) {
      showToast("$e", isSuccess: false);
    }
  }

  logoutSuperAdmin() async {
    try {
      String token = await getToken();
      String id = await getId();
      String name = await getName();
      // print("${token}${id}${name}");
      Response response = await dio.delete(
        'http://192.168.1.80:5000/api/auth/superadmin/token/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Optional content type
            'Authorization':
                'Bearer $token', // Include the token in the headers
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          clearStoredValues();
        });
        showToast("${response.data['message']}", isSuccess: true);
        navigateToScreen(context as BuildContext, AdminLogin());
      } else {
        showToast("${response.data['message']}", isSuccess: false);
      }
    } catch (e) {
      showToast("${e}", isSuccess: false);
    }
  }

//carete list and show cards
  final List<Map<String, String>> cardList = [];
  bool loader = false;
  List<Map<String, String>> cardData = [];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            // color: Colors.greenAccent,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<String>(
                future: getName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Welcome to the ${capitalize("${snapshot.data}")},',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Text(
                              //   'Phone: ${superadminData['phone'].toString()}',
                              // ),
                              // Text(
                              //   'Email: ${superadminData['email'].toString()}',
                              // ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              logoutSuperAdmin();
                            },
                            child: Icon(
                              Icons.logout,
                              color: const Color.fromARGB(255, 241, 242, 242),
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue)),
                          ),
                        ],
                      ),
                    ]);
                  }
                },
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                loader
                    ? SuperAdminCard(cardList: cardList)
                    : SizedBox(
                        height: 40.0,
                        width: 40, // Adjust the height as needed
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    isvalue
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: ListView.builder(
                              itemCount: admins.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> admin =
                                    admins[index]; // Get admin data at index
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: AssetImage(
                                          'assets/images/school_icon.png'),
                                    ),
                                    title: Text(
                                      'Name:${capitalize(admin['school_name'])}', // Assuming 'name' field exists
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            showDeleteOption(
                                                context, admin['id']);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ))
                        : LinearProgressIndicator(
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddAdmin()));
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class SuperAdminCard extends StatelessWidget {
  final List<Map<String, String>> cardList;

  SuperAdminCard({required this.cardList});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cardList.map((value) {
          return SizedBox(
            width: 140, // Set width for each card
            child: _makeCard(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _makeCard(Map<String, String> value) {
    return Card(
      color: Colors.blue[600],
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    value['title'] ?? '',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    value['content'] ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool loader = false;
  List<Map<String, String>> cardData = [];
  List<dynamic> totalStudent = [];

  logout() async {
    try {
      String token = await getId();
      String id = await getId();

      Response response =
          await dio.delete("http://192.168.1.80:5000/api/auth/admin/token/$id");
      await clearStoredValues(token, id);
      if (response.statusCode == 200) {
        showToast("${response.data['message']}", isSuccess: true);

        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(builder: (context) => AdminLogin()),
        );
      }
    } catch (e) {
      print(e);
      showToast("${e}", isSuccess: false);
    }
  }

  fetchTotalStudent() async {
    try {
      String schoolId = await getId();
      Response response = await dio
          .get('http://192.168.1.80:5000/api/admin/$schoolId/totalstudent');
      if (response.statusCode == 200) {
        cardData.add({
          "title": response.data["title"].toString(),
          "content": response.data["totalStudents"].toString(),
        });
      }
    } catch (e) {
      showToast("${e}", isSuccess: false);
    }
  }

  fetchTotalClass() async {
    try {
      String schoolId = await getId();
      Response response = await dio
          .get('http://192.168.1.80:5000/api/admin/$schoolId/totalclass');
      if (response.statusCode == 200) {
        cardData.add({
          "title": response.data["title"].toString(),
          "content": response.data["totalClass"].toString(),
        });
      }
    } catch (e) {
      showToast("${e}", isSuccess: false);
    }
  }

  fetchTotalTeacher() async {
    try {
      String schoolId = await getId();
      Response response = await dio
          .get('http://192.168.1.80:5000/api/admin/$schoolId/totalteacher');
      if (response.statusCode == 200) {
        cardData.add({
          "title": response.data["title"].toString(),
          "content": response.data["totalTeacher"].toString(),
        });
      }
    } catch (e) {
      showToast("${e}", isSuccess: false);
    }
  }

  fetchData() async {
    await fetchTotalStudent();
    await fetchTotalClass();
    await fetchTotalTeacher();
    setState(() {
      loader = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String capitalize(String input) {
    if (input == null || input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // Add more data as needed

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<String>(
                future: getName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Welcome to the ${capitalize("${snapshot.data}")},',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            logout();
                          },
                          child: Text('Logout'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CourseList()));
                  },
                  child: Card(
                    color: Color.fromARGB(255, 119, 19, 158),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/course.png'),
                          ),
                          Text('Course',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SubjectList()));
                  },
                  child: Card(
                    color: Color.fromARGB(255, 119, 19, 158),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/subject.png'),
                          ),
                          Text(
                            'Subject',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => AssignTeacher()));
                  },
                  child: Card(
                    color: Color.fromARGB(255, 119, 19, 158),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/teacher.png'),
                          ),
                          Text('Assign Teacher',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // First Row with Two Columns
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TeacherList()));
                  },
                  child: Card(
                    color: Color.fromARGB(255, 119, 19, 158),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/add_teacher.png'),
                          ),
                          Text('Add Teacher',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ClassList()));
                  },
                  child: Card(
                    color: Color.fromARGB(255, 119, 19, 158),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/class.png'),
                          ),
                          Text('Add Class',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => StudentList()));
                  },
                  child: Card(
                    color: Color.fromARGB(255, 105, 40, 129),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/student_icon.png'),
                          ),
                          Text('Add Student',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Add more Expanded widgets for additional columns
            ],
          ),
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loader
                  ? MyHorizontalScrollableCard(cardData: cardData)
                  : SizedBox(
                      height: 40.0,
                      width: 40, // Adjust the height as needed
                      child: CircularProgressIndicator(
                        color: Color(0xFF580778),
                      ),
                    ),
            ],
          )),
          // ListView Below
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AttendanceReport()));
                  },
                  leading: Image.asset(
                    'assets/images/report.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Attendance Report'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SummaryReport()));
                  },
                  leading: Image.asset(
                    'assets/images/summary.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Summary Report'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/images/all_report.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('All Generate Reports'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/images/report.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Summary Report'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                // Add more ListTiles as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyHorizontalScrollableCard extends StatelessWidget {
  final List<Map<String, String>> cardData;

  MyHorizontalScrollableCard({required this.cardData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cardData.map((data) {
          return SizedBox(
            width: 140, // Set width for each card
            child: _buildCard(data),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard(Map<String, String> data) {
    return Card(
      color: Color(0xFF580778),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    data['title'] ?? '',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    data['content'] ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// teacer scren
class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

Future<void> clearStoredValues(String token, String id) async {
  try {
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'id');
    await secureStorage.delete(key: 'name');
    await secureStorage.delete(key: 'schoo_id');
  } catch (e) {}
}

logoutTeacher(BuildContext context) async {
  try {
    String teacherId = await getId();
    String token = await getToken();

    Response response = await dio
        .delete("http://192.168.1.80:5000/api/auth/teacher/token/$teacherId");
    if (response.statusCode == 200) {
      await clearStoredValues(token, teacherId);
      showToast("${response.data['message']}", isSuccess: true);
      navigateToScreen(context, AdminLogin());
    } else {
      showToast("${response.data['message']}", isSuccess: false);
    }
  } catch (e) {
    showToast("Error", isSuccess: false);
  }
}

class _TeacherScreenState extends State<TeacherScreen> {
  String capitalize(String input) {
    if (input == null || input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  late Future<String> teacherIdFuture;
  late Future<String> teacherNameFuture;
  late Future<String> schoolIdFuture;
  late Future<String> teacherToken;

  @override
  void initState() {
    super.initState();
    teacherIdFuture = getId();
    teacherNameFuture = getName();
    schoolIdFuture = getSchoolId();
    teacherToken = getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<String>(
                future: getName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Welcome to the ${capitalize("${snapshot.data}")},',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            logoutTeacher(context);
                          },
                          child: Text('Logout'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(10),
          //   child: Center(
          //       child: Column(
          //     children: [
          //       FutureBuilder<String>(
          //         future: teacherIdFuture,
          //         builder: (context, snapshot) {
          //           return Text(
          //               "Teacher Id = ${snapshot.data ?? 'Loading...'}");
          //         },
          //       ),
          //       FutureBuilder<String>(
          //         future: teacherNameFuture,
          //         builder: (context, snapshot) {
          //           return Text(
          //               "Teacher Name = ${snapshot.data ?? 'Loading...'}");
          //         },
          //       ),
          //       FutureBuilder<String>(
          //         future: schoolIdFuture,
          //         builder: (context, snapshot) {
          //           return Text("School Id = ${snapshot.data ?? 'Loading...'}");
          //         },
          //       ),
          //       FutureBuilder<String>(
          //         future: teacherToken,
          //         builder: (context, snapshot) {
          //           return Text("Token= ${snapshot.data ?? 'Loading...'}");
          //         },
          //       ),
          //     ],
          //   )),
          // ),

          // First Row with Two Columns
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showPopPop(context);
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => StudentList()));
                    // _showCardNameInputDialog(context);
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/student_icon.png'),
                          ),
                          Text('Student List'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showPopup(context);
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => AttandanceList()));
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/mark_std.png'),
                          ),
                          Text('Mark Attenedance'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Add more Expanded widgets for additional columns
            ],
          ),

          // ListView Below
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MonthlyReport()));
                  },
                  leading: Image.asset(
                    'assets/images/report.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Monthly Report'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SeeReport()));
                  },
                  leading: Image.asset(
                    'assets/images/report.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Attendance Report'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SummaryReport()));
                  },
                  leading: Image.asset(
                    'assets/images/summary.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Summary Report'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/images/all_report.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('All Generate Reports'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/images/report.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Summary Report'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                // Add more ListTiles as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text('Choose Attendance'),
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle the action for School Level
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SchoolAttendance()),
              ).then((_) {
                // Executed after SchoolAttendence screen is popped
                Navigator.of(context).pop();
              });
              // Navigator.of(context).pop();
            },
            child: Text('School Level'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle the action for +2 Level
              Navigator.of(context).pop();
            },
            child: Text('+2 Level'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AttandanceList()),
              ).then((_) {
                // Executed after SchoolAttendence screen is popped
                Navigator.of(context).pop();
              });
            },
            child: Text('Bachelor Level'),
          ),
        ],
        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
      );
    },
  );
}

void _showPopPop(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text('Choose Studebt List'),
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle the action for School Level
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowStudentSchool()),
              ).then((_) {
                // Executed after SchoolAttendence screen is popped
                Navigator.of(context).pop();
              });
              // Navigator.of(context).pop();
            },
            child: Text('School Level'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle the action for +2 Level
              Navigator.of(context).pop();
            },
            child: Text('+2 Level'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AttandanceList()),
              ).then((_) {
                // Executed after SchoolAttendence screen is popped
                Navigator.of(context).pop();
              });
            },
            child: Text('Bachelor Level'),
          ),
        ],
        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
      );
    },
  );
}

// unkenow screen
class UnknownRoleScreen extends StatelessWidget {
  const UnknownRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

//Wen cart is click
// void _showCardNameInputDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Enter ClassName'),
//         content: TextField(
//           decoration: InputDecoration(labelText: 'Class Name'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               // Perform action with the entered name
//               // You can access the entered name using the TextEditingController
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: Text('OK'),
//           ),
//         ],
//       );
//     },
//   );
// }
