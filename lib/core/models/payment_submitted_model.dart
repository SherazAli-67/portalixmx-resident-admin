import 'payment_model.dart';

class PaymentSubmittedModel {
  final String paymentByUID;
  final DateTime submittedOnDate;
  final DateTime? approvedOnDate;
  final String? receipt;
  final PaymentStatus paymentStatus;

  PaymentSubmittedModel({
    required this.paymentByUID,
    required this.submittedOnDate,
    this.approvedOnDate,
    this.receipt,
    this.paymentStatus = PaymentStatus.submitted,
  });

  PaymentSubmittedModel copyWith({
    String? paymentByUID,
    DateTime? submittedOnDate,
    DateTime? approvedOnDate,
    String? receipt,
    PaymentStatus? paymentStatus,
  }) {
    return PaymentSubmittedModel(
      paymentByUID: paymentByUID ?? this.paymentByUID,
      submittedOnDate: submittedOnDate ?? this.submittedOnDate,
      approvedOnDate: approvedOnDate ?? this.approvedOnDate,
      receipt: receipt ?? this.receipt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentByUID': paymentByUID,
      'submittedOnDate': submittedOnDate.toIso8601String(),
      'approvedOnDate': approvedOnDate?.toIso8601String(),
      'receipt': receipt,
      'paymentStatus': paymentStatus.index,
    };
  }

  factory PaymentSubmittedModel.fromMap(Map<String, dynamic> map) {
    PaymentStatus status = PaymentStatus.submitted;
    if (map['paymentStatus'] != null &&
        map['paymentStatus'] is int &&
        map['paymentStatus'] < PaymentStatus.values.length) {
      status = PaymentStatus.values[map['paymentStatus']];
    } else if (map['approvedOnDate'] != null) {
      status = PaymentStatus.received;
    }

    return PaymentSubmittedModel(
      paymentByUID: map['paymentByUID'] ?? '',
      submittedOnDate: map['submittedOnDate'] != null
          ? DateTime.parse(map['submittedOnDate'])
          : DateTime.now(),
      approvedOnDate: map['approvedOnDate'] != null
          ? DateTime.parse(map['approvedOnDate'])
          : null,
      receipt: map['receipt'],
      paymentStatus: status,
    );
  }
}
