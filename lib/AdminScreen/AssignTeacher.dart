// import 'package:attendance/Auth/AdminLogin.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';

// class AssignTeacher extends StatefulWidget {
//   const AssignTeacher({super.key});

//   @override
//   State<AssignTeacher> createState() => _AssignTeacherState();
// }

// class _AssignTeacherState extends State<AssignTeacher> {
//   String? _teacher;
//   List<dynamic> teacherList = [];

//   Future feathTeacher() async {
//     try {
//       Dio dio = Dio();
//       Response response =
//           await dio.get('http://192.168.1.80:5000/api/teacher/');

//       if (response.statusCode == 200) {
//         teacherList = response.data['data'];
//       } else {
//         showSimpleSnackBar(context, response.data['message']);
//       }
//     } catch (e) {
//       showSimpleSnackBar(context, "$e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     feathTeacher();
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Assign Teacher"),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: DropdownButtonFormField<String>(
//                 value: _teacher,
//                 onChanged: (String? newValue) {
//                   if (newValue != null) {
//                     setState(() {
//                       _teacher = newValue;
//                     });
//                   }
//                 },
//                 items: teacherList.map((teacher) {
//                   String teacherName = teacher['name'];
//                   return DropdownMenuItem<String>(
//                     value: teacherName,
//                     child: Text(teacherName),
//                   );
//                 }).toList(),
//                 decoration: InputDecoration(
//                   hintText: "Select Teacher List",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   // Additional decoration for the dropdown button
//                   // Remove the border
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please Select Year";
//                   }
//                   return null;
//                 },
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
