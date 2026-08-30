class PaymentSubmittedModel {
  final String paymentByUID;
  final DateTime submittedOnDate;
  final DateTime? approvedOnDate;
  final String? receipt;

  PaymentSubmittedModel({
    required this.paymentByUID,
    required this.submittedOnDate,
    this.approvedOnDate,
    this.receipt
  });

  PaymentSubmittedModel copyWith({
    String? paymentByUID,
    DateTime? submittedOnDate,
    DateTime? approvedOnDate,
    String? receipt
  }) {
    return PaymentSubmittedModel(
      paymentByUID: paymentByUID ?? this.paymentByUID,
      submittedOnDate: submittedOnDate ?? this.submittedOnDate,
      approvedOnDate: approvedOnDate ?? this.approvedOnDate,
      receipt: receipt ?? this.receipt
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentByUID': paymentByUID,
      'submittedOnDate': submittedOnDate.toIso8601String(),
      'approvedOnDate': approvedOnDate?.toIso8601String(),
      'receipt' : receipt
    };
  }

  factory PaymentSubmittedModel.fromMap(Map<String, dynamic> map) {
    return PaymentSubmittedModel(
      paymentByUID: map['paymentByUID'] ?? '',
      submittedOnDate: DateTime.parse(map['submittedOnDate']),
      approvedOnDate: map['approvedOnDate'] != null
          ? DateTime.parse(map['approvedOnDate'])
          : null,
        receipt: map['receipt']
    );
  }
}
