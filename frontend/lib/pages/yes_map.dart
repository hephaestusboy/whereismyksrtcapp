import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

class YesMapPage extends StatefulWidget {
  const YesMapPage({super.key, required this.busId});

  static String routeName = 'yes_map';
  static String routePath = '/yes_map';

  final String busId; // Add a parameter to receive the busId

  @override
  State<YesMapPage> createState() => _YesMapPageState();
}

class _YesMapPageState extends State<YesMapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    print('Bus ID: ${widget.busId}'); // Print the received busId
  }

  /// Requests location permission and retrieves current location
  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);

    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        await _getCurrentLocation();
      } else {
        setState(() {
          _isLoading = false;
          _error = "Location permission is required to show your location.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Error requesting location permission: $e";
      });
    }
  }

  /// Fetches user's current GPS location
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentLocation = newLocation;
          _isLoading = false;
          _error = null;
        });

        // Use WidgetsBinding to ensure the map is rendered before moving
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 15.0);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Error getting location: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bus Location',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/popup'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorMessage()
          : _buildMap(),
    );
  }

  /// Builds the error message widget
  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _requestLocationPermission,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  /// Builds the map widget
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation ?? const LatLng(10.0159, 76.3419),
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bus.tracker',
        ),
        if (_currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation!,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
      ],
    );
  }
}