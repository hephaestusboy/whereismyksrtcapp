import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class YesQRPage extends StatefulWidget {
  const YesQRPage({super.key});

  static String routeName = 'yes_qr';
  static String routePath = '/yes_qr';

  @override
  State<YesQRPage> createState() => _YesQRPageState();
}

class _YesQRPageState extends State<YesQRPage> {
  // Controller for the mobile scanner
  final MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/popup'); // Go back to popup page when back button is pressed
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "QR Code Scanner",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/popup'),
          ),
          actions: [
            // Torch toggle button
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => cameraController.toggleTorch(),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Color.fromARGB(255, 245, 243, 243)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Scan the QR Code Inside the Bus",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      // Handle the scanned QR code
                      print('Barcode detected: ${barcode.rawValue}');
                      // Navigate to another page or show a dialog with the result
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('QR Code Scanned'),
                          content: Text('Scanned Data: ${barcode.rawValue}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is removed
    cameraController.dispose();
    super.dispose();
  }
}