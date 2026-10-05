import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/beissab_api.dart';
import '../core/session.dart';
import '../widgets/common.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationState();
}

class _NotificationState extends State<NotificationScreen> {
  String value = 'täglich';
  bool busy = false;

  static const _pageBackground = Color(0xFFF7F9FC);
  static const _ink = Color(0xFF0D1222);
  static const _muted = Color(0xFF71819B);
  static const _soft = Color(0xFFF4F7FA);

  @override
  void initState() {
    super.initState();
    _readUserValue();
  }

  void _readUserValue() {
    final user = session.user ?? {};
    value = (user['notificationPreference'] ??
            user['notification_preference'] ??
            'täglich')
        .toString();
  }

  Future<void> change(String newValue) async {
    if (busy || newValue == value) return;

    final previousValue = value;
    setState(() {
      value = newValue;
      busy = true;
    });

    try {
      await userApi.notification(newValue);

      // PATCH bestätigt nur das Update. Danach den tatsächlich gespeicherten
      // Benutzer neu laden, damit UI und Session sicher denselben Stand haben.
      session.user = await userApi.me();

      if (!mounted) return;
      setState(() {
        _readUserValue();
        busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        value = previousValue;
        busy = false;
      });
      snack(context, '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 78,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18, top: 7, bottom: 7),
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.pop(),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _ink,
                size: 24,
              ),
            ),
          ),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'B E I S S A B',
              style: TextStyle(
                color: Color(0xFF7C6CFF),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Benachrichtigungen',
              style: TextStyle(
                color: _ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE5EAF1)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 116),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFDDE3EC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF6C63FF),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E-Mail',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Wähle, ob und wie oft BeissAb dich erinnern soll.',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _option(
                  keyValue: 'sofort',
                  title: 'Sofort',
                  subtitle: 'Du bekommst Erinnerungen direkt.',
                ),
                const SizedBox(height: 9),
                _option(
                  keyValue: 'täglich',
                  title: 'Täglich',
                  subtitle: 'Einmal am Tag, empfohlen.',
                ),
                const SizedBox(height: 9),
                _option(
                  keyValue: 'nie',
                  title: 'Aus',
                  subtitle: 'Keine E-Mail-Benachrichtigungen.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _option({
    required String keyValue,
    required String title,
    required String subtitle,
  }) {
    final selected = value == keyValue;

    return Material(
      color: selected ? const Color(0xFF020817) : _soft,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: busy ? null : () => change(keyValue),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 69),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF020817)
                  : const Color(0xFFDDE3EC),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : _ink,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
