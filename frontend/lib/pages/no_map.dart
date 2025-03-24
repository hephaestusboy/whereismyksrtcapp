import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class NoMapPage extends StatefulWidget {
  const NoMapPage({super.key, required this.busId, required this.routeInfo});

  static String routeName = 'no_map';
  static String routePath = '/no_map';

  final String busId;
  final Map<String, dynamic> routeInfo;

  @override
  State<NoMapPage> createState() => _NoMapPageState();
}

class _NoMapPageState extends State<NoMapPage> {
  final MapController _mapController = MapController();
  LatLng? _busPosition;
  bool _isLoading = true;
  String? _error;
  Timer? _locationTimer;
  late final ApiService _apiService;
  double? _speed;
  String? _lastUpdated;

  double _ensureDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();

    if (widget.routeInfo.containsKey('latitude') &&
        widget.routeInfo.containsKey('longitude')) {
      _initializeFromRouteInfo();
    } else {
      _startLocationUpdates();
    }
  }

  void _initializeFromRouteInfo() {
    // Platform-agnostic type conversion
    final lat = _ensureDouble(widget.routeInfo['latitude']);
    final lng = _ensureDouble(widget.routeInfo['longitude']);

    setState(() {
      _busPosition = LatLng(lat, lng);
      _speed = _ensureDouble(widget.routeInfo['speed']);
      _lastUpdated = widget.routeInfo['updated_at']?.toString();
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_busPosition != null) {
        _mapController.move(_busPosition!, 15.0);
      }
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateBusLocation() async {
    try {
      final location = await _apiService.getBusLocation(widget.busId);
      print('Server response: $location'); // Debug log

      final lat = double.tryParse(location['latitude']?.toString() ?? '0');
      final lng = double.tryParse(location['longitude']?.toString() ?? '0');
      print('Parsed coordinates: ($lat, $lng)'); // Debug log

      if (lat != null && lng != null) {
        final newPosition = LatLng(lat, lng);
        print('New position: $newPosition'); // Debug log

        if (mounted) {
          setState(() {
            _busPosition = newPosition;
            _speed = double.tryParse(location['speed']?.toString() ?? '0');
            _lastUpdated = location['updated_at']?.toString();
            _isLoading = false;
            _error = null;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_busPosition != null) {
              _mapController.move(_busPosition!, 15.0);
            }
          });
        }
      } else {
        throw "Invalid location data received";
      }
    } catch (e) {
      print('Error updating bus location: $e'); // Debug log
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
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateBusLocation();
    });
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
          : _buildMapWithInfo(),
    );
  }

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
            onPressed: _updateBusLocation,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWithInfo() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _busPosition ?? const LatLng(10.0159, 76.3419),
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.bus.tracker',
            ),
            if (_busPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: _busPosition!,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                        Positioned(
                          top: 4,
                          child: Icon(
                            Icons.directions_bus,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),

        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _buildInfoCard(),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Destination",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      widget.routeInfo['destination'] ?? 'Unknown Destination',
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
                      "Bus ID",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      widget.busId,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem("Speed", "${_speed?.toStringAsFixed(1) ?? '0'} km/h",
                    _speed != null && _speed! > 60 ? Colors.red : Colors.green),
                _buildInfoItem("Updated", _formatLastUpdated(_lastUpdated), Colors.blue),
                _buildInfoItem("Status", _busPosition != null ? "Moving" : "Stopped",
                    _busPosition != null ? Colors.green : Colors.orange),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.5, end: 0),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatLastUpdated(String? timestamp) {
    if (timestamp == null) return "Just now";
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) return "Just now";
      if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
      if (difference.inHours < 24) return "${difference.inHours}h ago";
      return "${difference.inDays}d ago";
    } catch (e) {
      return timestamp;
    }
  }
}