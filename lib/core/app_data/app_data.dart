import 'package:flutter/cupertino.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import '../../l10n/app_localizations.dart';
import '../models/emergency_contact_model.dart';

class AppData {
  static  List<String> getDays(BuildContext context) {
    return [
      AppLocalizations.of(context)!.monday,
      AppLocalizations.of(context)!.tuesday,
      AppLocalizations.of(context)!.wednesday,
      AppLocalizations.of(context)!.thursday,
      AppLocalizations.of(context)!.friday,
      AppLocalizations.of(context)!.saturday,
      AppLocalizations.of(context)!.sunday
    ];
  }

  static String getDayByID(BuildContext context, int id){
    switch(id){
      case 0:
        return AppLocalizations.of(context)!.monday;
      case 1:
        return AppLocalizations.of(context)!.tuesday;
      case 2:
        return AppLocalizations.of(context)!.wednesday;
      case 3:
        return AppLocalizations.of(context)!.thursday;
      case 4:
        return AppLocalizations.of(context)!.friday;
      case 5:
        return AppLocalizations.of(context)!.saturday;
      case 6:
        return AppLocalizations.of(context)!.sunday;
      default:
        return AppLocalizations.of(context)!.monday;
    }
  }

  static List<EmergencyContactModel> get emergencyContacts {
    return [
      EmergencyContactModel(id: 1, name: "Isela Trujillo", phoneNumber: "+92 3072215500"),
      EmergencyContactModel(id: 1, name: "Sheraz Ali", phoneNumber: "+92 3072215500"),

    ];
  }



  static List<PaymentModel> get adminPayments {
    return [
      PaymentModel(
        paymentID: DateTime(2026, 1, 1).toUtc().toIso8601String(),
          paymentForTitle: "Rent",
          description: 'January Monthly Fees',
          amount: 99,
          societyID: '1',
          paymentByUID: 'w6xqzx3wGVbVn92iV4BVQSVQaqf1',
          paymentType: .paymentToAdmin,
          dateTime: DateTime(2026, 1, 1).toUtc(),
      ),
      PaymentModel(
        paymentID: DateTime(2026, 2, 1).toUtc().toIso8601String(),
        paymentForTitle: "Rent",
        description: 'February Monthly Fees',
        amount: 99,
        societyID: '1',
        paymentByUID: 'w6xqzx3wGVbVn92iV4BVQSVQaqf1',
        paymentType: .paymentToAdmin,
        dateTime: DateTime(2026, 2, 1).toUtc(),
      ),
      PaymentModel(
        paymentID: DateTime(2026, 3, 1).toUtc().toIso8601String(),
        paymentForTitle: "Rent",
        description: 'March Monthly Fees',
        amount: 99,
        societyID: '1',
        paymentByUID: 'w6xqzx3wGVbVn92iV4BVQSVQaqf1',
        paymentType: .paymentToAdmin,
        dateTime: DateTime(2026, 3, 1).toUtc(),
      ),
    ];
  }
}