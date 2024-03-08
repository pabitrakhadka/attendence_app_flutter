// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMe extends StatelessWidget {
  const AboutMe({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {"title": "+9809790721", "icon": Icons.contact_phone},
      {"title": "pabitrakhadka424@gmail.com", "icon": Icons.email},
      {"title": "khadkapabitra.com.np", "icon": Icons.link},
      {"title": "Chhatreshwori-3,Salyan", "icon": Icons.location_on},
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "About Me",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            children: [
              CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('assets/images/pk.jpg')),
              Text(
                "Pabitra Khadka",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Text("App/Web Developer"),
              TextButton(
                onPressed: () {
                  _launchURL(
                      "https://www.facebook.com/pabitra.khadka.3367174/");
                },
                child: Icon(
                  Icons.facebook,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft, // Align the text to the left
                  child: Text("Contact Info",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                      leading: Icon(items[index]['icon']),
                      title: Text(items[index]['title']),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}

// _launchURL(String url) async {
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Error $url';
  }
}
