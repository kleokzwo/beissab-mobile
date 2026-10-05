import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutz'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: const [
          Text(
            'Deine Daten',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'BeissAb verwendet deine Account-, Haushalts- und Planungsdaten, '
            'um deine Essensplanung bereitzustellen. Die Mobile-App speichert '
            'den Login-Token im geschützten Gerätespeicher.',
          ),
          SizedBox(height: 18),
          Text(
            'Serverdaten und rechtliche Datenschutzinformationen richten sich '
            'weiterhin nach der BeissAb-Datenschutzerklärung des bestehenden '
            'Dienstes.',
          ),
        ],
      ),
    );
  }
}
