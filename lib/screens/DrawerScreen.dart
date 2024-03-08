// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/screens/AboutMe.dart';
import 'package:attendance/screens/Setting.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DrawerScreen extends StatefulWidget {
  final String role;

  DrawerScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  static const String baseUrl = 'http://localhost:5000/api/auth/';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Function to clear stored values on logout

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.zero,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Student Attandance Management System"),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/admin_ad.jpg'),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Setting()));
              },
              leading: Icon(Icons.settings),
              title: Text("Setting"),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
            // Other list tile items...
            ListTile(
              onTap: () {},
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
      ),
    );
  }
}
