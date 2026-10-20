import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? AndroidDebugProvider()
        : AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? AppleDebugProvider()
        : AppleDeviceCheckProvider(),
  );
  try {
    final token = await FirebaseAppCheck.instance.getToken(true);
    if (token == null || token.isEmpty) {
      throw StateError('App Check returned an empty token');
    }
    if (kDebugMode) {
      debugPrint('App Check token acquired');
    }
  } catch (e) {
    debugPrint(
      'App Check failed. Register this device debug token in Firebase Console → '
      'App Check → Apps → your iOS/Android app → Manage debug tokens. '
      'Also check the Xcode/Logcat line that prints the Firebase App Check Debug Token. Error: $e',
    );
    if (kDebugMode) {
      rethrow;
    }
  }
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
