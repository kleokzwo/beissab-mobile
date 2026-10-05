import 'package:flutter/material.dart';

import '../api/beissab_api.dart';
import '../core/session.dart';
import '../widgets/common.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationState();
}

class _NotificationState extends State<NotificationScreen> {
  late String value;
  bool busy = false;

  @override
  void initState() {
    super.initState();

    value = (
      session.user?['notificationPreference'] ??
      session.user?['notification_preference'] ??
      'täglich'
    ).toString();
  }

  Future<void> change(String? newValue) async {
    if (newValue == null || busy) {
      return;
    }

    setState(() {
      busy = true;
    });

    try {
      await userApi.notification(newValue);

      if (mounted) {
        setState(() {
          value = newValue;
        });
      }
    } catch (error) {
      if (mounted) {
        snack(context, '$error');
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benachrichtigungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Wann möchtest du E-Mail-Erinnerungen erhalten?',
          ),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: value,
            onChanged: busy ? (_) {} : change,
            child: Column(
              children: {
                'sofort': 'Sofort',
                'täglich': 'Täglich',
                'nie': 'Aus',
              }.entries.map((entry) {
                return RadioListTile<String>(
                  value: entry.key,
                  title: Text(
                    entry.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    entry.key == 'sofort'
                        ? 'Erinnerungen direkt.'
                        : entry.key == 'täglich'
                            ? 'Einmal am Tag, empfohlen.'
                            : 'Keine E-Mail-Benachrichtigungen.',
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
