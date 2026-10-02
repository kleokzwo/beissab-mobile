import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/beissab_api.dart';
import '../core/config.dart';
import '../core/session.dart';
import '../widgets/common.dart';

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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text('${session.user?['email'] ?? 'Account'}'),
              subtitle: const Text('Angemeldetes Konto'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.groups),
                  title: const Text('Familie & Ernährung'),
                  onTap: () => context.push('/family'),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Benachrichtigungen'),
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: () async {
              await session.logout();

              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Abmelden'),
          ),
        ],
      ),
    );
  }
}

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyState();
}

class _FamilyState extends State<FamilyScreen> {
  String household = 'single';
  String diet = 'all';

  int children = 1;
  int time = 25;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    final user = session.user ?? {};

    household = (
      user['householdType'] ??
      user['household_type'] ??
      'single'
    ).toString();

    diet = (
      user['dietType'] ??
      user['diet_type'] ??
      'all'
    ).toString();

    children = int.tryParse(
          '${user['childrenCount'] ?? user['children_count'] ?? 1}',
        ) ??
        1;

    time = int.tryParse(
          '${user['maxCookingTime'] ?? user['max_cooking_time'] ?? 25}',
        ) ??
        25;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Familie verwalten'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            initialValue: ['single', 'paar', 'familie'].contains(household)
                ? household
                : 'single',
            decoration: const InputDecoration(
              labelText: 'Haushalt',
            ),
            items: const [
              DropdownMenuItem(
                value: 'single',
                child: Text('Single'),
              ),
              DropdownMenuItem(
                value: 'paar',
                child: Text('Paar'),
              ),
              DropdownMenuItem(
                value: 'familie',
                child: Text('Familie'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                household = value ?? 'single';
              });
            },
          ),
          if (household == 'familie') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: children,
              decoration: const InputDecoration(
                labelText: 'Anzahl Kinder',
              ),
              items: [1, 2, 3, 4, 5]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text('$value'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  children = value ?? 1;
                });
              },
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: diet,
            decoration: const InputDecoration(
              labelText: 'Ernährung',
            ),
            items: const [
              DropdownMenuItem(
                value: 'all',
                child: Text('Alles'),
              ),
              DropdownMenuItem(
                value: 'vegetarian',
                child: Text('Vegetarisch'),
              ),
              DropdownMenuItem(
                value: 'vegan',
                child: Text('Vegan'),
              ),
              DropdownMenuItem(
                value: 'pescatarian',
                child: Text('Fisch'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                diet = value ?? 'all';
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: time,
            decoration: const InputDecoration(
              labelText: 'Kochzeit',
            ),
            items: [15, 20, 25, 30, 35, 45]
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text('bis $value Minuten'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                time = value ?? 25;
              });
            },
          ),
          const SizedBox(height: 22),
          AsyncButton(
            label: 'Speichern',
            busy: busy,
            onPressed: () async {
              setState(() {
                busy = true;
              });

              try {
                final response = await userApi.household({
                  'householdType': household,
                  'childrenCount': household == 'familie' ? children : 0,
                  'dietType': diet,
                  'maxCookingTime': time,
                });

                session.user = {
                  ...(session.user ?? {}),
                  ...(response is Map
                      ? (response['user'] is Map
                          ? Map<String, dynamic>.from(response['user'])
                          : Map<String, dynamic>.from(response))
                      : <String, dynamic>{}),
                };

                if (context.mounted) {
                  snack(context, 'Gespeichert.');
                }
              } catch (error) {
                if (context.mounted) {
                  snack(context, '$error');
                }
              } finally {
                if (context.mounted) {
                  setState(() {
                    busy = false;
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

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