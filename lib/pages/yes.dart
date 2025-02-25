import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'yes_2.dart'; // Import the next page

class YesPage extends StatefulWidget {
  const YesPage({super.key});

  @override
  _YesPageState createState() => _YesPageState();
}

class _YesPageState extends State<YesPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = "";

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code!;
      });
      if (scannedData.isNotEmpty) {
        controller.dispose();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Yes2Page(qrData: scannedData)),
        );
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (scannedData.isEmpty)
                  ? Text("Scan a QR code")
                  : Text("Scanned: $scannedData"),
            ),
          ),
        ],
      ),
    );
  }
}
