import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/beissab_api.dart';
import '../core/session.dart';
import '../widgets/common.dart';

class AuthFrame extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const AuthFrame(
      {required this.title,
      required this.subtitle,
      required this.child,
      super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(children: [
                        Image.asset('assets/brand/beissab_logo.png',
                            height: 72,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.restaurant, size: 64)),
                        const SizedBox(height: 24),
                        Text(title,
                            textAlign: TextAlign.center,
                            style: Theme.of(c)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text(subtitle, textAlign: TextAlign.center),
                        const SizedBox(height: 28),
                        child
                      ]))))));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final e = TextEditingController(), p = TextEditingController();
  bool busy = false, show = false;
  Future<void> go() async {
    setState(() => busy = true);
    try {
      final r = await authApi.login(e.text.trim(), p.text);
      final t = r is Map
          ? (r['token'] ?? r['accessToken'] ?? r['data']?['token'])
          : null;
      if (t == null) throw Exception('Kein Token erhalten');
      await session.acceptToken('$t');
      if (!mounted) return;
      context.go(await session.onboardingDone() ? '/app' : '/onboarding');
    } catch (x) {
      if (mounted) snack(context, '$x');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(c) => AuthFrame(
      title: 'Willkommen zurück',
      subtitle: 'Melde dich bei BeissAb an.',
      child: Column(children: [
        TextField(
            controller: e,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'E-Mail', hintText: 'name@beispiel.de')),
        const SizedBox(height: 14),
        TextField(
            controller: p,
            obscureText: !show,
            decoration: InputDecoration(
                labelText: 'Passwort',
                suffixIcon: IconButton(
                    onPressed: () => setState(() => show = !show),
                    icon:
                        Icon(show ? Icons.visibility_off : Icons.visibility)))),
        const SizedBox(height: 18),
        AsyncButton(label: 'Anmelden', busy: busy, onPressed: go),
        TextButton(
            onPressed: () => context.go('/forgot-password'),
            child: const Text('Passwort vergessen?')),
        TextButton(
            onPressed: () => context.go('/register'),
            child: const Text('Noch kein Konto? Registrieren'))
      ]));
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegState();
}

class _RegState extends State<RegisterScreen> {
  final e = TextEditingController(), p = TextEditingController();
  bool busy = false;
  Future<void> go() async {
    if (p.text.length < 6) {
      snack(context, 'Passwort muss mindestens 6 Zeichen haben.');
      return;
    }
    setState(() => busy = true);
    try {
      await authApi.register(e.text.trim(), p.text);
      if (mounted) context.go('/verify-email', extra: e.text.trim());
    } catch (x) {
      if (mounted) snack(context, '$x');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(c) => AuthFrame(
      title: 'Konto erstellen',
      subtitle: 'Starte mit deinem persönlichen Essensplan.',
      child: Column(children: [
        TextField(
            controller: e,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-Mail')),
        const SizedBox(height: 14),
        TextField(
            controller: p,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Passwort', hintText: 'Mindestens 6 Zeichen')),
        const SizedBox(height: 18),
        AsyncButton(label: 'Registrieren', busy: busy, onPressed: go),
        TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Bereits registriert? Anmelden'))
      ]));
}

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({required this.email, super.key});
  @override
  State<VerifyEmailScreen> createState() => _VerifyState();
}

class _VerifyState extends State<VerifyEmailScreen> {
  late final e = TextEditingController(text: widget.email);
  final code = TextEditingController();
  bool busy = false;
  Future<void> go() async {
    setState(() => busy = true);
    try {
      final r = await authApi.verify(e.text.trim(), code.text.trim());
      final t = r is Map
          ? (r['token'] ?? r['accessToken'] ?? r['data']?['token'])
          : null;
      if (t != null) {
        await session.acceptToken('$t');
        if (mounted) context.go('/onboarding');
      } else if (mounted) {
        snack(context, 'E-Mail bestätigt. Bitte anmelden.');
        context.go('/login');
      }
    } catch (x) {
      if (mounted) snack(context, '$x');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(c) => AuthFrame(
      title: 'E-Mail bestätigen',
      subtitle: 'Gib den Bestätigungscode ein.',
      child: Column(children: [
        TextField(
            controller: e,
            decoration: const InputDecoration(labelText: 'E-Mail')),
        const SizedBox(height: 14),
        TextField(
            controller: code,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Code', hintText: '123456')),
        const SizedBox(height: 18),
        AsyncButton(label: 'Bestätigen', busy: busy, onPressed: go),
        TextButton(
            onPressed: () async {
              try {
                await authApi.resend(e.text.trim());
                if (mounted) snack(context, 'Code erneut gesendet.');
              } catch (x) {
                if (mounted) snack(context, '$x');
              }
            },
            child: const Text('Code erneut senden'))
      ]));
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotState();
}

class _ForgotState extends State<ForgotPasswordScreen> {
  final e = TextEditingController();
  bool busy = false;
  @override
  Widget build(c) => AuthFrame(
      title: 'Passwort vergessen?',
      subtitle: 'Wir senden dir einen Link zum Zurücksetzen.',
      child: Column(children: [
        TextField(
            controller: e,
            decoration: const InputDecoration(labelText: 'E-Mail')),
        const SizedBox(height: 18),
        AsyncButton(
            label: 'Link senden',
            busy: busy,
            onPressed: () async {
              setState(() => busy = true);
              try {
                await authApi.forgot(e.text.trim());
                if (mounted) snack(context, 'E-Mail wurde versendet.');
              } catch (x) {
                if (mounted) snack(context, '$x');
              } finally {
                if (mounted) setState(() => busy = false);
              }
            }),
        TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Zurück zur Anmeldung'))
      ]));
}

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({required this.token, super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetState();
}

class _ResetState extends State<ResetPasswordScreen> {
  final a = TextEditingController(), b = TextEditingController();
  bool busy = false;
  @override
  Widget build(c) => AuthFrame(
      title: 'Neues Passwort',
      subtitle: 'Vergib ein neues sicheres Passwort.',
      child: Column(children: [
        TextField(
            controller: a,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Neues Passwort')),
        const SizedBox(height: 14),
        TextField(
            controller: b,
            obscureText: true,
            decoration:
                const InputDecoration(labelText: 'Passwort wiederholen')),
        const SizedBox(height: 18),
        AsyncButton(
            label: 'Passwort speichern',
            busy: busy,
            onPressed: () async {
              if (a.text.length < 8 || a.text != b.text) {
                snack(context,
                    'Passwörter stimmen nicht überein oder sind zu kurz.');
                return;
              }
              setState(() => busy = true);
              try {
                await authApi.reset(widget.token, a.text);
                if (mounted) {
                  snack(context, 'Passwort geändert.');
                  context.go('/login');
                }
              } catch (x) {
                if (mounted) snack(context, '$x');
              } finally {
                if (mounted) setState(() => busy = false);
              }
            })
      ]));
}
