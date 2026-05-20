import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/features/card_scanner/presentation/card_scanner_screen.dart';
import 'package:smart_scanner/features/passbook_scanner/passbook_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Smart Scanner'),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Select Parser',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/card-scanner'),
              child: Text('Card Scanner'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/passbook-scanner'),
              child: Text('Passbook Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
