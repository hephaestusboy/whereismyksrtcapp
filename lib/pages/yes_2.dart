import 'package:flutter/material.dart';

class Yes2Page extends StatelessWidget {
  final String qrData;

  const Yes2Page({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scanned QR Code:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              qrData, // Display QR Code Data
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
