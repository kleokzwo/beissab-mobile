import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.settings_rounded, 'Einstellungen', 'App, Account und Pro-Abo', '/settings'),
      (Icons.groups_rounded, 'Familie verwalten', 'Haushalt und Kinderanzahl ändern', '/family'),
      (Icons.notifications_rounded, 'Benachrichtigungen', 'E-Mail ein oder ausschalten', '/notifications'),
      (Icons.shield_rounded, 'Datenschutz', 'Daten, Privatsphäre und Account löschen', '/privacy'),
      (Icons.auto_awesome_rounded, 'Neu in BeissAb ${AppConfig.appVersion}', 'Planung & Vorschläge verbessert', '/changelog'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 116),
      children: [
        const Text('M E H R', style: TextStyle(color: Color(0xFF6657C8), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.2)),
        const SizedBox(height: 8),
        const Text('Mehr Optionen', style: TextStyle(fontSize: 31, height: 1, fontWeight: FontWeight.w900, letterSpacing: -1)),
        const SizedBox(height: 9),
        const Text('Alles, was nicht in den schnellen Alltagsflow gehört.', style: TextStyle(color: Color(0xFF8A909B), fontSize: 13.5, height: 1.35)),
        const SizedBox(height: 25),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push(item.$4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 13, 13),
                child: Row(children: [
                  Container(width: 47, height: 47, decoration: BoxDecoration(color: const Color(0xFFF0F1F5), borderRadius: BorderRadius.circular(15)), child: Icon(item.$1, color: const Color(0xFF242936), size: 22)),
                  const SizedBox(width: 13),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.$2, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF181C25))),
                    const SizedBox(height: 4),
                    Text(item.$3, style: const TextStyle(fontSize: 11.5, color: Color(0xFF9298A3), fontWeight: FontWeight.w500)),
                  ])),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFB5BAC2), size: 23),
                ]),
              ),
            ),
          ),
        )),
      ],
    );
  }
}
