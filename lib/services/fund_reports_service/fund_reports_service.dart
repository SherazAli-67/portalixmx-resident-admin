import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/fund_report_model.dart';
import '../../core/res/firebase_constant.dart';

class FundReportsService {
  static final FundReportsService _instance = FundReportsService._internal();
  factory FundReportsService() => _instance;
  FundReportsService._internal();

  static FundReportsService get instance => _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getReportsCollection() {
    return _firestore.collection(FirebaseConst.fundReportsCol);
  }

  Future<List<FundReportModel>> getReports(String societyID) async {
    try {
      final snapshot = await _getReportsCollection()
          .where('societyID', isEqualTo: societyID)
          .get();
      return snapshot.docs
          .map((doc) =>
              FundReportModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get fund reports: $e');
    }
  }

  Future<void> createReport(FundReportModel report) async {
    try {
      await _getReportsCollection().doc(report.id).set(report.toMap());
    } catch (e) {
      throw Exception('Failed to create fund report: $e');
    }
  }

  Future<void> updateReport(FundReportModel report) async {
    try {
      await _getReportsCollection().doc(report.id).update(report.toMap());
    } catch (e) {
      throw Exception('Failed to update fund report: $e');
    }
  }
}
