// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class SummaryReport extends StatefulWidget {
  const SummaryReport({super.key});

  @override
  State<SummaryReport> createState() => _SummaryReportState();
}

class _SummaryReportState extends State<SummaryReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Summary Report",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(children: [
        ElevatedButton(
          onPressed: () {
            _selectDate(context);
          },
          child: Text('Select Date'),
        ),
        Expanded(
            child: Container(
          alignment: Alignment.center,
          height: 100,
          width: double.infinity,
          color: Color.fromARGB(255, 255, 253, 253),
          child: Text(
            "No Data",
            style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                fontFamily: "Time New Roman",
                color: Colors.white),
          ),
        ))
      ]),
    );
  }
}

Future<void> _selectDate(BuildContext context) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null && pickedDate != DateTime.now()) {
    print('Selected date: $pickedDate');
  } else {
    print('Date picker was canceled.');
  }
}
