enum PaymentType {
  paymentByResident,   // 0
  paymentToAdmin,      // 1
}

enum PaymentStatus {
  pending,   // 0
  received,      // 1
}

class PaymentModel {
  final String paymentID;
  final String paymentForTitle;
  final String description;
  final double amount;
  final String societyID;
  final String paymentByUID;
  final PaymentType paymentType;
  final PaymentStatus paymentStatus;
  final DateTime dateTime;

  PaymentModel({
    required this.paymentID,
    required this.paymentForTitle,
    required this.description,
    required this.amount,
    required this.societyID,
    required this.paymentByUID,
    required this.paymentType,
    this.paymentStatus = .pending,
    required this.dateTime
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentID': paymentID,
      'paymentForTitle': paymentForTitle,
      'description': description,
      'amount': amount,
      'societyID': societyID,
      'paymentByUID': paymentByUID,
      'dateTime': dateTime.toIso8601String(),
      'paymentType': paymentType.index,
      'paymentStatus' :  paymentStatus.index
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      paymentID: map['paymentID'] ?? '',
      paymentForTitle: map['paymentForTitle'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      societyID: map['societyID'] ?? '',
      paymentByUID: map['paymentByUID'] ?? '',
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'])
          : DateTime.now(),
      paymentType: (map['paymentType'] != null &&
          map['paymentType'] < PaymentType.values.length)
          ? .values[map['paymentType']]
          : .paymentByResident,
      paymentStatus: (map['paymentStatus'] != null &&
          map['paymentStatus'] < PaymentStatus.values.length)
          ? .values[map['paymentType']]
          : .pending,
    );
  }
}