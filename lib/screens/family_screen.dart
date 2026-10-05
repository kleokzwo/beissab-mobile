import 'package:flutter/material.dart';

import '../api/beissab_api.dart';
import '../core/session.dart';
import '../widgets/common.dart';

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
