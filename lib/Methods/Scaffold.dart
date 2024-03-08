import 'package:flutter/material.dart';

Scaffold buildScaffold(
  String title,
  Widget bodyWidget,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        "${title}",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color(0xFF580778),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    body: bodyWidget,
  );
}
