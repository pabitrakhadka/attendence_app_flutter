import 'dart:async';
import 'package:attendance/Auth/AdminLogin.dart';
import 'package:attendance/Auth/db.dart';
import 'package:attendance/Methods/getTokenData.dart';
import 'package:attendance/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:attendance/Methods/getTokenData.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Student Attendance Management System",
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String token;
  late String role;
  late Future<String> tokenFuture;
  late Future<String> roleFuture;

  @override
  void initState() {
    super.initState();
    loadToken();
    Future.delayed(Duration(seconds: 4)).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              token.isNotEmpty ? HomePage(role) : AdminLogin(),
        ),
      );
    });
  }

  loadToken() async {
    try {
      String t = await getToken();
      String userRole = await getRole();
      setState(() {
        token = t;
        role = userRole;
      });
    } catch (e) {
      setState(() {
        token = "";
        role = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF580778),
      body: Center(
        child: AnimatedTextKit(animatedTexts: [
          TypewriterAnimatedText(
            "Attendance Management System",
            textStyle: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontFamily: 'Agne',
            ),
            speed: const Duration(milliseconds: 100),
          ),
        ]),
      ),
    );
  }
}
