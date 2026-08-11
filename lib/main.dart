import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/providers/home_provider.dart';
import 'package:portalixmx_resident_admin/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'core/res/app_colors.dart';
import 'core/res/app_constants.dart';
import 'firebase_messaging_background.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/authentication_provider/authentication_provider.dart';
import 'providers/language_provider.dart';
import 'router/app_router.dart';
import 'services/push_notification_service/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final profileProvider = ProfileProvider();
  final GoRouter router = createAppRouter(profileProvider);
  await PushNotificationService.instance.initialize(router: router);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => LocaledProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => profileProvider),
      ],
      child: MyApp(routerConfig: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.routerConfig});

  final GoRouter routerConfig;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaledProvider>(context);

    return MaterialApp.router(
      title: AppConstants.appTitle,
      locale: provider.getLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
          fontFamily: AppConstants.appFontFamily,
          colorScheme:
              ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
          scaffoldBackgroundColor: AppColors.primaryColor,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppColors.primaryColor,
          )),
      builder: (ctx, child) {
        return child!;
      },
      routerConfig: routerConfig,
    );
  }
}
