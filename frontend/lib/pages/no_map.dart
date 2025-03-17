import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import 'dart:async';

class NoMapScreen extends StatefulWidget {
  final Map<String, dynamic> routeInfo;
  final ApiService? apiService;

  const NoMapScreen({
    super.key,
    required this.routeInfo,
    this.apiService,
  });

  static String routeName = 'NoMapScreen';
  static String routePath = '/no-map';

  @override
  State<NoMapScreen> createState() => _NoMapScreenState();
}

class _NoMapScreenState extends State<NoMapScreen> {
  late final ApiService _apiService;
  Map<String, dynamic>? _busLocation;
  Timer? _locationTimer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateBusLocation() async {
    try {
      final location = await _apiService.getBusLocation(widget.routeInfo['busId'].toString());
      if (mounted) {
        setState(() {
          _busLocation = location;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _startLocationUpdates() {
    // Initial update
    _updateBusLocation();
    
    // Set up periodic updates every 30 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateBusLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Route"),
        backgroundColor: Colors.redAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updateBusLocation,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Map Image with Bus Location
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://cdn-images-1.medium.com/max/1024/1*gpJFqG9Np7o75-6Wl5hXGg.png',
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (_busLocation != null)
                          Positioned(
                            left: _busLocation!['latitude'] * 100, // Convert coordinates to screen position
                            top: _busLocation!['longitude'] * 100,
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Destination Details Card
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
                                  widget.routeInfo['destination'],
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
                                          "Last Updated",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          _busLocation?['updated_at'] ?? 'N/A',
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
                                          "Status",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          _busLocation?['status'] ?? 'On Route',
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
