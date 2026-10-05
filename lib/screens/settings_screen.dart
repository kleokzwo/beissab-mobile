import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config.dart';
import '../core/session.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pageBackground = Color(0xFFF7F9FC);
    const ink = Color(0xFF0D1222);
    const muted = Color(0xFF64748B);
    const purple = Color(0xFF5B55F7);

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
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
                color: ink,
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
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Einstellungen',
              style: TextStyle(
                color: ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD7DEFF), Color(0xFFD7FFF0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'APP',
                  style: TextStyle(
                    color: purple,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Allgemeine Einstellungen',
                  style: TextStyle(
                    color: ink,
                    fontSize: 27,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Account, Datenschutz und später dein Pro-Abo.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFDDE3EC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.workspace_premium_outlined,
                        color: Color(0xFFFF9800), size: 23),
                    SizedBox(width: 11),
                    Text(
                      'BeissAb Pro',
                      style: TextStyle(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      disabledBackgroundColor: const Color(0xFF9894F2),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Subscribe bald verfügbar',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _settingsTile(
            icon: Icons.shield_outlined,
            title: 'Datenschutz',
            subtitle: 'Daten und Privatsphäre',
            onTap: () => context.push('/privacy'),
          ),
          const SizedBox(height: 14),
          _settingsTile(
            icon: Icons.delete_outline_rounded,
            title: 'Account löschen',
            subtitle: 'Bald verfügbar',
            enabled: false,
            danger: true,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () async {
                await session.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF2D2D),
                side: const BorderSide(color: Color(0xFFFFD1D1)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 19),
              label: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'BeissAb Version ${AppConfig.appVersion}',
              style: TextStyle(
                color: Color(0xFFA8B3C7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool enabled = true,
    bool danger = false,
  }) {
    final iconColor = danger ? const Color(0xFFFF6B72) : const Color(0xFF243047);
    final iconBackground = danger ? const Color(0xFFFFF5F5) : const Color(0xFFF1F5F9);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE0E6EE)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled ? const Color(0xFF0D1222) : const Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
