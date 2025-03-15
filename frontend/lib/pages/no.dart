import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoPage extends StatefulWidget {
  const NoPage({super.key});

  static String routeName = 'no';
  static String routePath = '/no';

  @override
  State<NoPage> createState() => _NoPageState();
}

class _NoPageState extends State<NoPage> with SingleTickerProviderStateMixin {
  String? startLocation;
  String? destination;
  bool isSearched = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  final List<String> locations = [
    "Kochi", "Thrissur", "Alappuzha", "Kottayam", "Kozhikode",
    "Kannur", "Palakkad", "Malappuram", "Trivandrum", "Kasaragod"
  ];

  @override
  void initState() {
    super.initState();
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

  void _searchBus() {
    if (startLocation != null && destination != null) {
      setState(() {
        isSearched = true;
      });
      _animationController.forward();
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
          onPressed: _searchBus,
          icon: const Icon(Icons.search, color: Colors.white),
          label: const Text("Search", style: TextStyle(color: Colors.white)),
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
    return Container(
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
                      text: "01",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 144, 5, 5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$startLocation - $destination",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("15 Minutes away", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  context.push('/no-map', extra: destination);
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
