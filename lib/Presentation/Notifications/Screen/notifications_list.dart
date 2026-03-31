import 'package:flutter/material.dart';

class NotificationsListScreen extends StatelessWidget {
  const NotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const SafeArea(
        child: Center(child: Text('No notification details available.')),
      ),
    );
  }
}
