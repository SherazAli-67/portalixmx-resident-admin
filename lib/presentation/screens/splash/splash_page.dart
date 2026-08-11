import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portalixmx_resident_admin/providers/profile_provider.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<ProfileProvider>(
          builder: (context, p, _) {
            final auth = FirebaseAuth.instance.currentUser != null;
            if (!p.loadingProfile && p.user == null && auth) {
              return IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => p.reloadCurrentUser(),
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
