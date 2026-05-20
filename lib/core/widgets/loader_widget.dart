import 'package:flutter/material.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 12),
        Text(
          'Scanning card...',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
