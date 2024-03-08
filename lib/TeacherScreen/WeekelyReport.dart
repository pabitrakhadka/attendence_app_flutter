import 'dart:io';

import 'package:attendance/Methods/Scaffold.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io'; // Import the dart:io library for file operations
import 'package:path_provider/path_provider.dart'; //

class WeekelyReport extends StatefulWidget {
  const WeekelyReport({super.key});

  @override
  State<WeekelyReport> createState() => _WeekelyReportState();
}

class _WeekelyReportState extends State<WeekelyReport> {
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    try {
      await GeneratePdf();
    } catch (e) {}
  }

  GeneratePdf() async {
    Future<void> generatePDF() async {
      // Create a new PDF document
      final pdf = pw.Document();

      // Add a page to the document
      pdf.addPage(
        pw.MultiPage(
          // Build function to add content to each page
          build: (pw.Context context) => [
            // Title: Attendance Report
            pw.Center(
              child: pw.Text('Attendance Report',
                  style: pw.TextStyle(fontSize: 40)),
            ),
            // Weekly Attendance Report
            pw.SizedBox(height: 20),
            pw.Text('Weekly Attendance Report',
                style: pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 10),
            // Table: S.N, Student Name, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday
            pw.Table.fromTextArray(
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: [
                'S.N',
                'Student Name',
                'Sunday',
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday'
              ],
              data: [
                ['1', 'John Doe', 'P', 'A', 'P', 'P', 'P', 'A'],
                ['2', 'Jane Smith', 'P', 'P', 'A', 'P', 'P', 'P'],
                // Add more rows as needed
              ],
            ),
          ],
        ),
      );

      // Save the document to a file
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/attendance_report.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Show a message indicating the file path
      print('PDF saved to: $filePath');
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
        "Weekely Report",
        Center(
          child: Column(
            children: [
              SfPdfViewer.asset("name"),
            ],
          ),
        ));
  }
}
