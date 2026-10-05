import 'package:flutter/material.dart';

import '../core/config.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Was ist neu?'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'BeissAb ${AppConfig.appVersion}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              title: Text(
                'Native Mobile App',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                'Flutter/Dart Client mit Auth, Meal-Auswahl, Wochenplan, '
                'Einkaufsliste und Einstellungen.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
