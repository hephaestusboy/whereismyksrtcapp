import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  LatLng? _busPosition;
  Timer? _locationTimer;
  bool _isLoading = true;
  String? _error;

  final MapController _mapController = MapController(); // Map Controller

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

      if (location.containsKey('latitude') &&
          location.containsKey('longitude')) {
        final newPosition = LatLng(
          location['latitude'],
          location['longitude'],
        );

        if (mounted) {
          setState(() {
            _busPosition = newPosition;
            _isLoading = false;
            _error = null;
          });

          // Move map to the new bus position
          _mapController.move(_busPosition!, 13.0);
        }
      } else {
        throw "Invalid location data received.";
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
    _updateBusLocation();

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
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _busPosition ?? const LatLng(10.0159, 76.3419),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_busPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _busPosition!,
                        width: 40.0,
                        height: 40.0,
                        child: const Icon(
                          Icons.directions_bus,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Destination Details Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Destination",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.routeInfo['destination'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Last Updated", style: TextStyle(fontSize: 16, color: Colors.black54)),
                          Text(
                            _busPosition != null ? "Just Now" : 'N/A',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Status", style: TextStyle(fontSize: 16, color: Colors.black54)),
                          Text(
                            _busPosition != null ? 'On Route' : 'Not Available',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fade(duration: 600.ms).slideY(begin: 1, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
