import 'package:flutter/material.dart';

class ShowMessage extends StatefulWidget {
  const ShowMessage({super.key});

  @override
  State<ShowMessage> createState() => _ShowMessageState();
}

class _ShowMessageState extends State<ShowMessage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

void showSimpleSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(
          seconds: 3), // Duration for how long the SnackBar should be displayed
    ),
  );
}
