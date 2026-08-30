import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/models/community_event_model.dart';
import 'package:portalixmx_resident_admin/core/models/community_poll_model.dart';
import 'package:portalixmx_resident_admin/core/models/fund_report_model.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/presentation/screens/account_pending/account_pending_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/community_calendar/community_calendar.dart';
import 'package:portalixmx_resident_admin/presentation/screens/community_calendar/community_detail_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/community_polls/community_directory_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/community_polls/community_polls_detail_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/community_polls/community_polls_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/edit_profile/edit_profile_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/emergency_calls/emergency_calls_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/fund_management/fund_management_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/fund_management/fund_report_detail_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/main_menu/residents/residents_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/payment_to_admin_detail/payment_to_admin_detail_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/profile_detail/profile_detail_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/resident_payment_history/resident_payment_history_page.dart';
import 'package:portalixmx_resident_admin/presentation/screens/splash/splash_page.dart';
import 'package:portalixmx_resident_admin/providers/edit_community_provider/edit_community_provider.dart';
import 'package:portalixmx_resident_admin/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import '../core/models/access_request_model.dart';
import '../core/models/complaints_model.dart';
import '../presentation/screens/authentication/create_account_page.dart';
import '../presentation/screens/authentication/forget_password_page.dart';
import '../presentation/screens/authentication/login_page.dart';
import '../presentation/screens/authentication/otp_page.dart';
import '../presentation/screens/edit_community/edit_community_page.dart';
import '../presentation/screens/main_menu/access/access_page.dart';
import '../presentation/screens/main_menu/access/access_summary_page.dart';
import '../presentation/screens/main_menu/homepage/home_page.dart';
import '../presentation/screens/main_menu/maintenance/complaint_summary_page.dart';
import '../presentation/screens/main_menu/maintenance/maintenance_page.dart';
import '../presentation/screens/main_menu/payments_menu.dart';
import '../presentation/screens/main_menu/profile_menu/profile_page.dart';
import '../presentation/screens/main_menu/main_menu.dart';
import '../presentation/screens/payment_detail/payment_detail_page.dart';
import '../presentation/screens/payments_to_admin/payments_to_admin_page.dart';
import '../presentation/screens/transfer_ownership/transfer_ownership_page.dart';

GoRouter createAppRouter(ProfileProvider profileProvider) {
  return GoRouter(
    initialLocation: NamedRoutes.home.routeName,
    refreshListenable: profileProvider,
    routes: [
      GoRoute(
        path: NamedRoutes.splash.routeName,
        builder: (ctx, state) => SplashPage(),
      ),
      GoRoute(
          path: NamedRoutes.createAccount.routeName,
          builder: (ctx, state) => CreateAccountPage()),
      GoRoute(
          path: NamedRoutes.login.routeName,
          builder: (ctx, state) => LoginPage()),
      GoRoute(
          path: NamedRoutes.forgetPassword.routeName,
          builder: (ctx, state) => ForgetPasswordPage()),
      GoRoute(
          path: NamedRoutes.pendingRequest.routeName,
          builder: (ctx, state) => PendingRequestPage()),
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, navigationShell) {
          return MainMenuPage(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: NamedRoutes.home.routeName,
                builder: (ctx, state) => HomePage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: NamedRoutes.paymentsBilling.routeName,
                builder: (ctx, state) => PaymentsMenu())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: NamedRoutes.maintenance.routeName,
                builder: (ctx, state) => MaintenanceMenu())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: NamedRoutes.accessRequests.routeName,
                builder: (ctx, state) => AccessMenu())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: NamedRoutes.profile.routeName,
                builder: (ctx, state) => ProfileMenu())
          ]),
        ],
      ),
      GoRoute(
          path: NamedRoutes.residents.routeName,
          builder: (ctx, state) =>ResidentsPage()),
      GoRoute(
          path: NamedRoutes.paymentDetail.routeName,
          builder: (ctx, state) =>PaymentDetailPage(payment: state.extra as PaymentModel)),
      GoRoute(
          path: NamedRoutes.residentPaymentHistory.routeName,
          builder: (ctx, state) =>ResidentPaymentHistoryPage(userID: state.extra as String)),
      GoRoute(
          path: NamedRoutes.accessRequestDetail.routeName,
          builder: (ctx, state) =>
              AccessSummaryPage(access: state.extra as AccessRequestModel)),
      GoRoute(
          path: NamedRoutes.complaintSummary.routeName,
          builder: (ctx, state) => ComplaintSummaryPage(
                complaint: state.extra as ComplaintModel,
              )),
      GoRoute(
          path: NamedRoutes.privacyPolicy.routeName,
          builder: (ctx, state) =>
              Center(child: Text("Privacy Policy Page"))),
      GoRoute(
          path: NamedRoutes.verifyOtp.routeName,
          builder: (ctx, state) => VerifyOTPPage()),
      GoRoute(
          path: NamedRoutes.residentDetail.routeName,
          builder: (ctx, state) =>
              ProfileDetailPage(resident: state.extra as UserModel)),
      GoRoute(
          path: NamedRoutes.editProfile.routeName,
          builder: (ctx, state) => EditProfilePage()),
      GoRoute(
          path: NamedRoutes.communityCalendar.routeName,
          builder: (ctx, state) => CommunityCalendarPage()),
      GoRoute(
          path: NamedRoutes.communityCalendarDetail.routeName,
          builder: (ctx, state) =>
              CommunityDetailPage(event: state.extra as CommunityEventModel)),
      GoRoute(
          path: NamedRoutes.communityPolls.routeName,
          builder: (ctx, state) => CommunityPollsPage()),
      GoRoute(
          path: NamedRoutes.communityPollsDetail.routeName,
          builder: (ctx, state) =>
              CommunityPollsDetailPage(poll: state.extra as CommunityPollModel)),
      GoRoute(
          path: NamedRoutes.paymentsToAdmin.routeName,
          builder: (ctx, state) => PaymentsToAdminPage()),
      GoRoute(
          path: NamedRoutes.editCommunity.routeName,
          builder: (ctx, state) => ChangeNotifierProvider(
              create: (_)=> EditUpdateCommunityProvider(),
              child: EditCommunity())),
      GoRoute(
          path: NamedRoutes.transferOwnership.routeName,
          builder: (ctx, state) => const TransferOwnershipPage()),
      GoRoute(
          path: NamedRoutes.communityDirectory.routeName,
          builder: (ctx, state) => CommunityDirectoryPage()),
      GoRoute(
          path: NamedRoutes.paymentsToAdminDetail.routeName,
          builder: (ctx, state) => PaymentToAdminDetailPage(payment: state.extra as PaymentModel)),
      GoRoute(
          path: NamedRoutes.emergencyCall.routeName,
          builder: (ctx, state) => EmergencyCallsPage()),
      GoRoute(
          path: NamedRoutes.fundManagement.routeName,
          builder: (ctx, state) => FundManagementPage()),
      GoRoute(
          path: NamedRoutes.fundReportDetail.routeName,
          builder: (ctx, state) => FundReportDetailPage(
              report: state.extra as FundReportModel)),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final loc = state.matchedLocation;
      final isAuthenticated = FirebaseAuth.instance.currentUser != null;
      final loading = profileProvider.loadingProfile;
      final user = profileProvider.user;

      final isOnLoginPage = loc == NamedRoutes.login.routeName;
      final isOnSignupPage = loc == NamedRoutes.createAccount.routeName;
      final isOnForgetPasswordPage =
          loc == NamedRoutes.forgetPassword.routeName;
      final isOnSplash = loc == NamedRoutes.splash.routeName;
      final isOnPending = loc == NamedRoutes.pendingRequest.routeName;
      final isVerifyOtp = loc == NamedRoutes.verifyOtp.routeName;
      final isPrivacy = loc == NamedRoutes.privacyPolicy.routeName;

      final authScreens = isOnLoginPage ||
          isOnSignupPage ||
          isOnForgetPasswordPage ||
          isVerifyOtp ||
          isPrivacy;

      if (!isAuthenticated) {
        if (isOnSplash) {
          return NamedRoutes.createAccount.routeName;
        }
        if (authScreens) {
          return null;
        }
        return NamedRoutes.createAccount.routeName;
      }

      if (isAuthenticated && loading) {
        if (isOnSplash) {
          return null;
        }
        return NamedRoutes.splash.routeName;
      }

      if (isAuthenticated && !loading && user == null) {
        if (isOnSplash) {
          return null;
        }
        return NamedRoutes.splash.routeName;
      }

      if (user!.status == UserStatus.pending) {
        if (isOnPending) {
          return null;
        }
        return NamedRoutes.pendingRequest.routeName;
      }

      if (isOnPending ||
          isOnSplash ||
          isOnLoginPage ||
          isOnSignupPage ||
          isOnForgetPasswordPage ||
          isVerifyOtp) {
        return NamedRoutes.home.routeName;
      }

      return null;
    },
  );
}

enum NamedRoutes {
  splash('/splash'),
  createAccount('/create-account'),
  login("/login"),
  forgetPassword('/forget-password'),
  pendingRequest("/pending-request"),
  home('/home'),
  residents('/residents'),
  paymentsBilling('/payments-billing'),
  maintenance('/maintenance'),
  accessRequests('/access-requests'),
  profile('/profile-menu'),
  accessRequestDetail('/access-request-detail'),
  complaintSummary('/complaint-detail'),
  privacyPolicy('/privacy-policy'),
  verifyOtp('/verify-otp'),
  residentDetail('/resident-detail'),
  editProfile('/edit-profile'),
  communityCalendar('/community-calendar'),
  communityCalendarDetail('/community-calendar-detail'),
  communityPolls('/community-polls'),
  paymentDetail('/payment-detail'),
  residentPaymentHistory('/resident-payment-history'),
  communityPollsDetail('/community-polls-detail'),
  paymentsToAdmin('/payments-to-admin'),
  paymentsToAdminDetail('/payments-to-admin-detail'),
  editCommunity('/edit-community'),
  transferOwnership('/transfer-ownership'),
  emergencyCall('/emergency-calls'),
  communityDirectory('/community-edit_community'),
  fundManagement('/fund-management'),
  fundReportDetail('/fund-report-detail'),
  ;

  final String routeName;
  const NamedRoutes(this.routeName);
}
