enum PaymentType {
  paymentByResident,   // 0
  paymentToAdmin,      // 1
}

enum PaymentStatus {
  pending,   // 0
  received,      // 1
  submitted,    // 2
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
  final String? receipt;

  PaymentModel({
    required this.paymentID,
    required this.paymentForTitle,
    required this.description,
    required this.amount,
    required this.societyID,
    required this.paymentByUID,
    required this.paymentType,
    this.paymentStatus = .pending,
    required this.dateTime,
    this.receipt
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
      'paymentStatus' :  paymentStatus.index,
      'receipt' : receipt
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
          ? .values[map['paymentStatus']]
          : .pending,
      receipt: map['receipt']
    );
  }
  PaymentModel copyWith({
    String? paymentID,
    String? paymentForTitle,
    String? description,
    double? amount,
    String? societyID,
    String? paymentByUID,
    PaymentType? paymentType,
    PaymentStatus? paymentStatus,
    DateTime? dateTime,
    String? receipt
  }) {
    return PaymentModel(
      paymentID: paymentID ?? this.paymentID,
      paymentForTitle: paymentForTitle ?? this.paymentForTitle,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      societyID: societyID ?? this.societyID,
      paymentByUID: paymentByUID ?? this.paymentByUID,
      paymentType: paymentType ?? this.paymentType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      dateTime: dateTime ?? this.dateTime,
      receipt: receipt ?? this.receipt
    );
  }
}