// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Portalixmx';

  @override
  String get residentLogin => 'Resident Admin Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get forgetPassword => 'Forget your password';

  @override
  String get enterEmailToSendPasswordReset =>
      'Enter email address, a password reset link will be sent to that';

  @override
  String get forgetPassLinkSent => 'Password reset link sent';

  @override
  String get checkYourEmailAddress =>
      'Please check your email address, a password reset link sent to it.';

  @override
  String accountRequestPending(Object societyName) {
    return 'Your admin request for $societyName is pending. You will be notified as the admin update your request';
  }

  @override
  String get uploadYourProfileImage => 'Please upload your profile image';

  @override
  String welcomeMessage(Object name) {
    return 'Welcome $name';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get dashboardDescription =>
      'Here’s an overview of residents, payments, and requests';

  @override
  String get totalResidents => 'Total Residents';

  @override
  String get acceptedRequests => 'Accepted requests';

  @override
  String get totalPayments => 'Payments';

  @override
  String get totalComplaints => 'Total Complaints';

  @override
  String get totalAccess => 'Total Access Requests';

  @override
  String get accessRequests => 'Access Requests';

  @override
  String get viewAll => 'View All';

  @override
  String get paymentDetail => 'Payment Details';

  @override
  String residentsOfTheSociety(Object society) {
    return 'Residents of the $society';
  }

  @override
  String get poolAccess => 'Pool Access';

  @override
  String get joinedOn => 'Joined On';

  @override
  String get residents => 'Residents';

  @override
  String get newRequests => 'New Requests';

  @override
  String get emptyResidentsMsg =>
      'The residents of the society will appear here';

  @override
  String get emptyResidentRequestsMsg =>
      'The new requests from the residents will appear here';

  @override
  String get approve => 'Approve';

  @override
  String get paymentDetails => 'Payment Details';

  @override
  String get paymentFor => 'Payment for';

  @override
  String get status => 'Status';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Amount';

  @override
  String get receipt => 'Payment Receipt';

  @override
  String get add => 'Add';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get received => 'Received';

  @override
  String get markAsResolved => 'Mark as resolved';

  @override
  String get markAsInProgress => 'Mark as In-progress';

  @override
  String get markAsReceived => 'Mark as received';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get paymentToAdmin => 'Payment to Admin';

  @override
  String get reject => 'Reject';

  @override
  String get aboutResident => 'About Resident';

  @override
  String get houseNumber => 'House Number';

  @override
  String get aboutComplaint => 'About Complaint';

  @override
  String get createNewAccess => 'Create new access';

  @override
  String get title => 'Title';

  @override
  String get freeToUse => 'Free to use';

  @override
  String get setItFreeToUse => 'Set, Free to use';

  @override
  String get setItRequestToUse => 'Set, Request to use';

  @override
  String get createEvent => 'Create Event';

  @override
  String get eventTitle => 'Event Title';

  @override
  String get eventDescription => 'Enter details about the event';

  @override
  String get eventDateAndTime => 'Date & Time';

  @override
  String get twoStepVerification => '2 Step Verification';

  @override
  String get twoStepVerificationDescription =>
      'Enter the 2 step verification code sent on your email address';

  @override
  String get otp => 'OTP';

  @override
  String get submit => 'Submit';

  @override
  String get needHelp => 'Need Help';

  @override
  String get home => 'Home';

  @override
  String get payments => 'Payments';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get access => 'Access';

  @override
  String get menu => 'Menu';

  @override
  String get guest => 'Guest';

  @override
  String get requestedTime => 'REQUESTED TIME';

  @override
  String get accessFor => 'Access For';

  @override
  String get teacher => 'Teacher';

  @override
  String get accessApprovedDate => 'Access Approved Date';

  @override
  String get contactNum => 'Contact No';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get shareKey => 'Share Key';

  @override
  String get qrCode => 'QR CODE';

  @override
  String get paymentsAndBilling => 'Payments & Billing';

  @override
  String get currentService => 'Current Service';

  @override
  String get otherServices => 'Other Services';

  @override
  String get serviceName => 'Service Name';

  @override
  String get cleaningOfCommonAreas => 'Cleaning of common areas';

  @override
  String get garbageCollection => 'Garbage Collection';

  @override
  String get complaint => 'Complaint';

  @override
  String get uploadPhotos => 'Upload Photos';

  @override
  String get openCamera => 'Open Camera';

  @override
  String get requestAccess => 'Request Access';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get directory => 'Directory';

  @override
  String get communityCalendar => 'Community Calendar';

  @override
  String get communityPolls => 'Community Polls';

  @override
  String get createPoll => 'Create Poll';

  @override
  String get pollQuestion => 'Poll Question';

  @override
  String get addOption => 'Add Option';

  @override
  String get guards => 'Guards';

  @override
  String get carPooling => 'Car Pooling';

  @override
  String get emergencyCalls => 'Emergency Calls';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsCondition => 'Terms & Conditions';

  @override
  String get address => 'Address';

  @override
  String get societyInformationUpdated =>
      'Society information updated successfully';

  @override
  String get logout => 'Logout';

  @override
  String get search => 'Search';

  @override
  String get guardTracking => 'Guard Tracking';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String get vehicleInformation => 'Vehicle Information';

  @override
  String get vehicleName => 'Vehicle Name';

  @override
  String get licensePlateNumber => 'License Plate Number';

  @override
  String get registrationNumber => 'Registration Number';

  @override
  String get update => 'Update';

  @override
  String get color => 'Color';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String updateYour(Object userInfo) {
    return 'Update your $userInfo';
  }

  @override
  String get addGuest => 'Add Guest';

  @override
  String get deleteComplaint => 'Delete Complaint';

  @override
  String get profileInfoUpdated => 'Profile information updated';

  @override
  String get profileInfoUpdateFailed =>
      'Profile updating failed, Please try again';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get deleteVisitor => 'Delete Visitor';

  @override
  String get deleteGuest => 'Delete Guest';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get editGuest => 'Edit Guest';

  @override
  String get carPlateNumber => 'Car Plate Number';

  @override
  String get vehicleModel => 'Vehicle Model';

  @override
  String get time => 'Time';

  @override
  String get date => 'Date';

  @override
  String hasBeenEditedMessage(Object name) {
    return '$name has been updated';
  }

  @override
  String hasBeenAddedMessage(Object guestType, Object name) {
    return '$name has been added as a $guestType';
  }

  @override
  String accessRequestPending(Object accessTitle) {
    return 'The request for $accessTitle is already in pending state';
  }

  @override
  String accessRequestSubmitted(Object accessTitle) {
    return 'The request for $accessTitle is submitted to Portalix Admin';
  }

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountDescription =>
      'Create Portalixmx resident admin account and get started with the society management';

  @override
  String get selectSociety => 'Select society';

  @override
  String get alreadyHaveAnAccount => 'Already have an account? ';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? ';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get completeProfileDescription =>
      'Please provide the rest information to complete your profile';

  @override
  String get additionalDetails => 'Additional Details';

  @override
  String get pleaseEnterName => 'Please enter name';

  @override
  String get pleaseEnterContactNumber => 'Please enter contact number';

  @override
  String get pleaseEnterCarPlateNumber => 'Please enter car plate number';

  @override
  String get pleaseEnterVehicleModel => 'Please enter vehicle model';

  @override
  String get pleaseEnterColor => 'Please enter color';

  @override
  String get pleaseSelectFromDateTime => 'Please select from date and time';

  @override
  String get pleaseSelectToDateTime => 'Please select to date and time';

  @override
  String get toDateTimeMustBeAfterFromDateTime =>
      'To date/time must be after from date/time';

  @override
  String get pleaseSelectAtLeastOneDay =>
      'Please select at least one day with time';

  @override
  String get visitorAddedSuccessfully => 'Visitor added successfully';

  @override
  String get visitorUpdatedSuccessfully => 'Visitor updated successfully';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get error => 'Error';

  @override
  String get all => 'All';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get automaticVisitorCode => 'Visitor Code';

  @override
  String get generateAccessCode => 'Generate Access Code';

  @override
  String get communityMembers => 'Community Members';

  @override
  String get editCommunity => 'Edit Community';

  @override
  String get fundManagement => 'Fund Management';

  @override
  String get createFundReport => 'Create Fund Report';

  @override
  String get reportTitle => 'Report Title';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get expenseLabel => 'Expense Label';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get balance => 'Balance';

  @override
  String get note => 'Note';

  @override
  String get publishReport => 'Publish Report';

  @override
  String get saveAsDraft => 'Save as Draft';

  @override
  String get published => 'Published';

  @override
  String get draft => 'Draft';

  @override
  String get emptyFundReportsMsg => 'No fund reports yet';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get noExpenses => 'No expenses listed';
}
