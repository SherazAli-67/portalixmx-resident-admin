import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../core/models/access_request_model.dart';
import '../core/models/complaints_model.dart';
import '../presentation/screens/authentication/create_account_page.dart';
import '../presentation/screens/authentication/forget_password_page.dart';
import '../presentation/screens/authentication/login_page.dart';
import '../presentation/screens/authentication/otp_page.dart';
import '../presentation/screens/main_menu/access/access_page.dart';
import '../presentation/screens/main_menu/access/access_summary_page.dart';
import '../presentation/screens/main_menu/homepage/home_page.dart';
import '../presentation/screens/main_menu/maintenance/complaint_summary_page.dart';
import '../presentation/screens/main_menu/maintenance/maintenance_page.dart';
import '../presentation/screens/main_menu/payments_menu.dart';
import '../presentation/screens/main_menu/profile_menu/profile_page.dart';
import '../presentation/screens/main_menu/main_menu.dart';


GoRouter appRouter = GoRouter(
  initialLocation: NamedRoutes.createAccount.routeName,
  routes: [
    GoRoute(path: NamedRoutes.createAccount.routeName, builder: (ctx, state)=> CreateAccountPage()),
    GoRoute(path: NamedRoutes.login.routeName, builder: (ctx, state)=> LoginPage()),
      GoRoute(path: NamedRoutes.forgetPassword.routeName, builder: (ctx, state)=> ForgetPasswordPage()),
      StatefulShellRoute.indexedStack(
          builder: (ctx, state, navigationShell){
            return MainMenuPage(navigationShell: navigationShell,);
          },
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: NamedRoutes.home.routeName, builder: (ctx, state) => HomePage())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: NamedRoutes.paymentsBilling.routeName, builder: (ctx, state) => PaymentsMenu())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: NamedRoutes.maintenance.routeName, builder: (ctx, state) => MaintenanceMenu())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: NamedRoutes.accessRequests.routeName, builder: (ctx, state) => AccessMenu())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: NamedRoutes.profile.routeName, builder: (ctx, state) => ProfileMenu())
            ]),
          ]),
    GoRoute(path: NamedRoutes.accessRequestDetail.routeName, builder: (ctx, state)=> AccessSummaryPage(access: state.extra as AccessRequestModel)),
    GoRoute(path: NamedRoutes.complaintSummary.routeName, builder: (ctx, state)=> ComplaintSummaryPage(complaint: state.extra as ComplaintModel,)),

    GoRoute(path: NamedRoutes.privacyPolicy.routeName, builder: (ctx, state)=> Center(child: Text("Privacy Policy Page"),)),
    GoRoute(path: NamedRoutes.verifyOtp.routeName, builder: (ctx, state)=> VerifyOTPPage()),

  ],
/*  redirect: (BuildContext context, GoRouterState state) {
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;
    final isOnLoginPage = state.matchedLocation == NamedRoutes.login.routeName;
    final isOnSignupPage = state.matchedLocation == NamedRoutes.createAccount.routeName;
    final isOnForgetPasswordPage = state.matchedLocation == NamedRoutes.forgetPassword.routeName;
    final isOnCompleteProfilePage = state.matchedLocation == NamedRoutes.completeProfile.routeName;
    // final isOnVerifyOtpProfilePage = state.matchedLocation == NamedRoutes.verifyOtp.routeName;

    if (isAuthenticated && (isOnLoginPage || isOnSignupPage)) {
      return NamedRoutes.home.routeName;
    }

    if (!isAuthenticated && !isOnSignupPage && !isOnLoginPage && !isOnForgetPasswordPage && !isOnCompleteProfilePage) {
      return NamedRoutes.createAccount.routeName;
    }

    return null;
  },*/
);

enum NamedRoutes {
  createAccount('/create-account'),
  login("/login"),
  forgetPassword('/forget-password'),
  home('/home'),
  paymentsBilling('/payments-billing'),
  maintenance('/maintenance'),
  accessRequests('/access-requests'),
  profile('/profile-menu'),
  accessRequestDetail('/access-request-detail'),
  complaintSummary('/complaint-detail'),
  privacyPolicy('/privacy-policy'),
  verifyOtp('/verify-otp')
  ;
  final String routeName;
  const NamedRoutes(this.routeName);
}