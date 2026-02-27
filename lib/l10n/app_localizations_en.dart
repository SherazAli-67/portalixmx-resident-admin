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
  String get residentLogin => 'Resident Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get forgetPassword => 'Forget your password';

  @override
  String welcomeMessage(Object name) {
    return 'Welcome $name';
  }

  @override
  String get regularVisitors => 'Regular Visitors';

  @override
  String get guest => 'Guest';

  @override
  String get accessRequests => 'Access Requests';

  @override
  String get poolAccess => 'Pool Access';

  @override
  String get add => 'Add';

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
  String get regularVisitor => 'Regular Visitor';

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
  String get guards => 'Guards';

  @override
  String get carPooling => 'Car Pooling';

  @override
  String get emergencyCalls => 'Emergency Calls';

  @override
  String get privacyPolicy => 'Privacy Policy';

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
      'Create account with Portalixmx and get started with the society management';

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
  String get automaticVisitorCode => 'Visitor Code';

  @override
  String get generateAccessCode => 'Generate Access Code';
}
