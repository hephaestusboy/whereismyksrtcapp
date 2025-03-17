import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class NoPage extends StatefulWidget {
  final ApiService? apiService;
  const NoPage({super.key, this.apiService});

  static String routeName = 'no';
  static String routePath = '/no';

  @override
  State<NoPage> createState() => _NoPageState();
}

class _NoPageState extends State<NoPage> with SingleTickerProviderStateMixin {
  String? startLocation;
  String? destination;
  bool isSearched = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  late final ApiService _apiService;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  final List<String> locations = [
    "Kochi", "Thrissur", "Alappuzha", "Kottayam", "Kozhikode",
    "Kannur", "Palakkad", "Malappuram", "Trivandrum", "Kasaragod"
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _searchBus() async {
    if (startLocation != null && destination != null) {
      setState(() => _isLoading = true);
      
      try {
        final results = await _apiService.searchBuses(
          startLocation!,
          destination!,
        );
        
        setState(() {
          _searchResults = results;
          isSearched = true;
          _isLoading = false;
        });
        
        _animationController.forward();
      } catch (e) {
        setState(() => _isLoading = false);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select both Start Location and Destination"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Bus Tracker", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _showExitPopup(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown("Start Location", (value) {
              setState(() => startLocation = value);
            }),
            const SizedBox(height: 10),
            _buildDropdown("Destination", (value) {
              setState(() => destination = value);
            }),
            const SizedBox(height: 20),
            _buildAnimatedSearchButton(),
            const SizedBox(height: 20),
            if (isSearched) FadeTransition(
              opacity: _fadeInAnimation,
              child: _buildBusDetails(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(label, style: const TextStyle(color: Colors.black54)),
          value: label == "Start Location" ? startLocation : destination,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: onChanged,
          items: locations.map((String location) {
            return DropdownMenuItem(
              value: location,
              child: Text(location),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAnimatedSearchButton() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isSearched ? 180 : double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _searchBus,
          icon: _isLoading 
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.search, color: Colors.white),
          label: Text(_isLoading ? "Searching..." : "Search", 
            style: const TextStyle(color: Colors.white)
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }

  Widget _buildBusDetails(BuildContext context) {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          "No buses found for this route",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return Column(
      children: _searchResults.map((bus) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Bus ",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      TextSpan(
                        text: bus['id']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 144, 5, 5),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${bus['departure_point']} - ${bus['arrival_point']}",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bus['estimated_time'] ?? "Time not available",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    context.push('/no-map', extra: {
                      'busId': bus['id'],
                      'destination': bus['arrival_point']
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Text(
                      "Select Bus",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  void _showExitPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Exit"),
          content: const Text("Are you sure you want to go back?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/popup');
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
