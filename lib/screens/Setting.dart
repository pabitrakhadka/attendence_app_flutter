import 'package:attendance/screens/Admin.dart';
import 'package:flutter/material.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "General Setting",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),
            ),
            ListView(
              shrinkWrap:
                  true, // Use shrinkWrap to avoid vertical scrolling issues
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Admin()));
                  },
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text("Update Admin Profile"),
                  trailing: Icon(Icons.arrow_forward),
                ),
                ListTile(
                  onTap: () {
                    _showDeleteConfirmation(context);
                  },
                  leading: Icon(Icons.cut),
                  title: Text("Clear All Data"),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to Clear All data?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Perform delete action here
              // ...
              Navigator.of(context).pop(); // Close the dialog after deletion
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}
