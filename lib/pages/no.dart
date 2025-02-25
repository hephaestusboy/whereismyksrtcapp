import 'package:flutter/material.dart';

class NoPage extends StatelessWidget {
  const NoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('No Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
