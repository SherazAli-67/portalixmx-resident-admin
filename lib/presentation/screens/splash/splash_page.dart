import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:portalixmx_resident_admin/providers/profile_provider.dart';
import 'package:portalixmx_resident_admin/router/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _recoveryRequested = false;

  void _maybeRecover(ProfileProvider profile) {
    final auth = FirebaseAuth.instance.currentUser != null;
    if (_recoveryRequested || profile.loadingProfile || profile.user != null || !auth) {
      return;
    }
    _recoveryRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<ProfileProvider>().recoverFromFailedProfileLoad();
      if (!mounted) return;
      context.go(NamedRoutes.login.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<ProfileProvider>(
          builder: (context, p, _) {
            final auth = FirebaseAuth.instance.currentUser != null;
            if (!p.loadingProfile && p.user == null && auth) {
              _maybeRecover(p);
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
