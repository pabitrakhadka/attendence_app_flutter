import 'package:attendance/Methods/Scaffold.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Auth/db.dart';
import '../Methods/capitilize.dart';
import '../Methods/getTokenData.dart';
import '../Methods/showMessage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io'; // Import the dart:io library for file operations
import 'package:path_provider/path_provider.dart'; // Import the path_provider package for file paths

// import 'package:flutter_pdfview/flutter_pdfview.dart';

class SeeReport extends StatelessWidget {
  const SeeReport({super.key});

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
        "Attendence Report",
        Center(
          child: AttendedenceReport(),
        ));
  }
}

class AttendedenceReport extends StatefulWidget {
  const AttendedenceReport({super.key});

  @override
  State<AttendedenceReport> createState() => _AttendedenceReportState();
}

class _AttendedenceReportState extends State<AttendedenceReport> {
  late DateTime selectedDate = DateTime.now();
  List<dynamic> classList = [];
  bool isshowpdf = false;
  String? _selectedOption;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> generatePDF() async {
    // Create a new PDF document
    final pdf = pw.Document();

    // Add a page to the document
    pdf.addPage(
      pw.Page(
        build: (context) {
          // Add text to the page
          return pw.Center(
            child: pw.Text('Attendence Report ',
                style: pw.TextStyle(fontSize: 40)),
          );
        },
      ),
    );

    // Save the document to a file
    // Get the temporary directory
    Directory tempDir = await getTemporaryDirectory();
    // Construct the file path for the PDF
    String filePath = '${tempDir.path}/example.pdf';

    // Save the document to a file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Show a message indicating the file path
    print('PDF saved to: $filePath');
  }

  bool _isLoading = true;
  // late PDFDocument document;

  // loadDocument() async {
  //   document = await PDFDocument.fromAsset('assets/pdf/gyandep.pdf');

  //   setState(() => _isLoading = false);
  // }
  // Future<void> ferchDataAndSave() async {
  //   try {
  //     // setp 1 fetch data
  //     final response = await dio.get("path");

  //     //step 2 save too file
  //     final directory = await getExternalStorageDirectories();
  //     final file = File('${directory.path}/data.txt');
  //     await file.writeAsString(data);

  // generate pdf
  // final pdf = syncfusion.PdfDocument();
  // final page = pdf.pages.add();
  // final pageWidth = page.getClientSize().width;
  // final pageHeight = page.getClientSize().height;
  // final pdfText = syncfusion.PdfTextElement(data);
  // final pdfLayoutFormat =
  //     syncfusion.PdfLayoutFormat(layoutType: syncfusion.PdfLayoutType.paginate);
  // final result = pdfText.draw(
  //   page: page,
  //   bounds: syncfusion.Rect.fromLTWH(0, 0, pageWidth, pageHeight),
  //   format: pdfLayoutFormat,
  // );
  //   } catch (e) {}
  // }

  Future<void> fetchClasses() async {
    try {
      String schoolId = await getSchoolId();
      Response response =
          await dio.get("http://192.168.1.80:5000/api/teacher/$schoolId/class");

      if (response.statusCode == 200) {
        classList = response.data['data'];
        print("classlist=${classList}");
      } else {
        showToast('${response.data['message']}');
      }
    } catch (e) {
      showToast("$e");
      print("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select Start Date'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Start Date: ${selectedDate.toString().substring(0, 10)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Center(
                child: Text("To"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select End Date'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'End Date: ${selectedDate.toString().substring(0, 10)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          ],
        ),
        Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                    items: classList.map((classes) {
                      String item = classes['class_name'];
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(Capitalize(item)),
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
              // Expanded(
              //   child: SizedBox(
              //     height: MediaQuery.of(context)
              //         .size
              //         .height, // Adjust the height as needed
              //     width: MediaQuery.of(context)
              //         .size
              //         .width, // Adjust the width as needed
              //     child: SfPdfViewer.asset('assets/pdf/abc.pdf'),
              //   ),
              // ),
            ],
          ),
        ),
        // Expanded(
        //   child: SizedBox(
        //     height: MediaQuery.of(context)
        //         .size
        //         .height, // Adjust the height as needed
        //     width:
        //         MediaQuery.of(context).size.width, // Adjust the width as needed
        //     child: SfPdfViewer.asset('assets/pdf/gyandep.pdf'),
        //   ),
        // ),
      ],
    );
  }
}
