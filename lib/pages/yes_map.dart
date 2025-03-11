import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class YesMapPage extends StatefulWidget {
  const YesMapPage({super.key});

  static String routeName = 'yes_map';
  static String routePath = '/yes_map';

  @override
  _YesMapPageState createState() => _YesMapPageState();
}

class _YesMapPageState extends State<YesMapPage> {
  String? selectedDestination;
  int? estimatedTime;

  final Map<String, int> destinationTimes = {
    'Ernakulam': 10,
    'Aluva': 15,
    'Thrissur': 30,
    'Kottayam': 40,
    'Kollam': 60,
    'Trivandrum': 90
  };

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Exit Navigation"),
          content: const Text("Are you sure you want to exit navigation?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Stay on the page
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog first
                context.go('/popup');// Navigate to popup.dart
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Location"),
        backgroundColor: const Color.fromARGB(255, 244, 245, 244),
      ),
      body: Column(
        children: [
          // Map Image from URL
          Expanded(
            child: Center(
              child: Image.network(
                'https://cdn-images-1.medium.com/max/1024/1*gpJFqG9Np7o75-6Wl5hXGg.png',
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text("Failed to load map"));
                },
              ),
            ),
          ),

          // Destination Selection and Bus Info Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Destination Dropdown
                DropdownButtonFormField<String>(
                  value: selectedDestination,
                  hint: const Text("Select Destination"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: destinationTimes.keys.map((destination) {
                    return DropdownMenuItem(
                      value: destination,
                      child: Text(destination),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDestination = value;
                      estimatedTime = destinationTimes[value];
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Bus Location Info
                const Text(
                  "Bus Location: Near Kochi, Kerala",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Estimated Time Display
                Text.rich(
                  TextSpan(
                    text: selectedDestination == null
                        ? "Select a destination to see estimated time."
                        : "Your bus is currently at XYZ Stop and will reach ",
                    style: const TextStyle(fontSize: 16),
                    children: selectedDestination != null
                        ? [
                            TextSpan(
                              text: "$selectedDestination ",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: "in "),
                            TextSpan(
                              text: "$estimatedTime minutes.",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ]
                        : [],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Exit Navigation Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showExitDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Exit Navigation",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
