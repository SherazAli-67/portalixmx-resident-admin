enum FundReportStatus {
  draft,
  published,
}

class FundExpenseItem {
  final String id;
  final String label;
  final double amount;

  FundExpenseItem({
    required this.id,
    required this.label,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'amount': amount,
    };
  }

  factory FundExpenseItem.fromMap(Map<String, dynamic> map) {
    return FundExpenseItem(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }

  FundExpenseItem copyWith({
    String? id,
    String? label,
    double? amount,
  }) {
    return FundExpenseItem(
      id: id ?? this.id,
      label: label ?? this.label,
      amount: amount ?? this.amount,
    );
  }
}

class FundReportModel {
  final String id;
  final String societyID;
  final String createdBy;
  final String createdByUID;
  final DateTime createdAt;
  final int periodMonth;
  final int periodYear;
  final String title;
  final double income;
  final List<FundExpenseItem> expenses;
  final double balance;
  final String note;
  final FundReportStatus status;
  final DateTime? publishedAt;

  FundReportModel({
    required this.id,
    required this.societyID,
    required this.createdBy,
    required this.createdByUID,
    required this.createdAt,
    required this.periodMonth,
    required this.periodYear,
    required this.title,
    required this.income,
    required this.expenses,
    required this.balance,
    this.note = '',
    this.status = .draft,
    this.publishedAt,
  });

  double get totalExpenses =>
      expenses.fold(0.0, (sum, item) => sum + item.amount);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'societyID': societyID,
      'createdBy': createdBy,
      'createdByUID': createdByUID,
      'createdAt': createdAt.toIso8601String(),
      'periodMonth': periodMonth,
      'periodYear': periodYear,
      'title': title,
      'income': income,
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'balance': balance,
      'note': note,
      'status': status.index,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  factory FundReportModel.fromMap(Map<String, dynamic> map) {
    final expensesList = map['expenses'];
    return FundReportModel(
      id: map['id'] ?? '',
      societyID: map['societyID'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdByUID: map['createdByUID'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      periodMonth: map['periodMonth'] as int? ?? DateTime.now().month,
      periodYear: map['periodYear'] as int? ?? DateTime.now().year,
      title: map['title'] ?? '',
      income: (map['income'] ?? 0).toDouble(),
      expenses: expensesList is List
          ? expensesList
              .map((e) => FundExpenseItem.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      balance: (map['balance'] ?? 0).toDouble(),
      note: map['note'] ?? '',
      status: (map['status'] != null &&
              map['status'] < FundReportStatus.values.length)
          ? .values[map['status']]
          : .draft,
      publishedAt: map['publishedAt'] != null
          ? DateTime.parse(map['publishedAt'])
          : null,
    );
  }

  FundReportModel copyWith({
    String? id,
    String? societyID,
    String? createdBy,
    String? createdByUID,
    DateTime? createdAt,
    int? periodMonth,
    int? periodYear,
    String? title,
    double? income,
    List<FundExpenseItem>? expenses,
    double? balance,
    String? note,
    FundReportStatus? status,
    DateTime? publishedAt,
  }) {
    return FundReportModel(
      id: id ?? this.id,
      societyID: societyID ?? this.societyID,
      createdBy: createdBy ?? this.createdBy,
      createdByUID: createdByUID ?? this.createdByUID,
      createdAt: createdAt ?? this.createdAt,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      title: title ?? this.title,
      income: income ?? this.income,
      expenses: expenses ?? this.expenses,
      balance: balance ?? this.balance,
      note: note ?? this.note,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
