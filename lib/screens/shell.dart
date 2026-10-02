import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({required this.child, super.key});

  static const _navy = Color(0xFF111827);
  static const _lime = Color(0xFFC7F36B);

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = path.startsWith('/plan')
        ? 1
        : path.startsWith('/shopping')
            ? 2
            : path.startsWith('/more')
                ? 3
                : 0;

    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.calendar_month_rounded, 'Plan'),
      (Icons.shopping_bag_rounded, 'Einkauf'),
      (Icons.more_horiz_rounded, 'Mehr'),
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 10)),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == index;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => context.go(['/app', '/plan', '/shopping', '/more'][i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected ? _lime : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(items[i].$1, size: 22, color: selected ? _navy : Colors.white70),
                        const SizedBox(height: 3),
                        Text(
                          items[i].$2,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: selected ? _navy : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
