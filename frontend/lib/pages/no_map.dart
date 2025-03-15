import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NoMapScreen extends StatelessWidget {
  final String destination;

  const NoMapScreen({super.key, required this.destination});

  static String routeName = 'NoMapScreen';
  static String routePath = '/no-map';

  @override
  Widget build(BuildContext context) {
    // New Static Map Image URL
    const String mapUrl =
        'https://cdn-images-1.medium.com/max/1024/1*gpJFqG9Np7o75-6Wl5hXGg.png';

    // Dummy Destination Data
    const String reachingTime = "3:45 PM";
    const int minutesLeft = 12;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Route"),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          // Static Map Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              mapUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // Destination Details Card with Animation
          Expanded(
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Destination",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(thickness: 1, color: Colors.grey),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Reaching Time",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                reachingTime,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Arriving In",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                "$minutesLeft min",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: 1, end: 0, curve: Curves.easeOut),
            ),
          ),
        ],
      ),
    );
  }
}
