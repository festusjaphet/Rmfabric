import 'package:cloud_firestore/cloud_firestore.dart';

// Daily Report — stored in RM_reports_daily
class DailyReportModel {
  final String date; // YYYY-MM-DD (document ID)
  final double totalSales;
  final double totalCost;
  final double totalExpenses;
  final double totalProfit;
  final int totalTransactions;
  final String closedBy;
  final DateTime closedAt;

  DailyReportModel({
    required this.date,
    required this.totalSales,
    required this.totalCost,
    required this.totalExpenses,
    required this.totalProfit,
    required this.totalTransactions,
    required this.closedBy,
    required this.closedAt,
  });

  factory DailyReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyReportModel(
      date: doc.id,
      totalSales: (data['totalSales'] ?? 0).toDouble(),
      totalCost: (data['totalCost'] ?? 0).toDouble(),
      totalExpenses: (data['totalExpenses'] ?? 0).toDouble(),
      totalProfit: (data['totalProfit'] ?? 0).toDouble(),
      totalTransactions: (data['totalTransactions'] ?? 0).toInt(),
      closedBy: data['closedBy'] ?? '',
      closedAt: (data['closedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'totalSales': totalSales,
      'totalCost': totalCost,
      'totalExpenses': totalExpenses,
      'totalProfit': totalProfit,
      'totalTransactions': totalTransactions,
      'closedBy': closedBy,
      'closedAt': Timestamp.fromDate(closedAt),
    };
  }
}

// Day status — stored in RM_days
class DayStatusModel {
  final String date; // YYYY-MM-DD (document ID)
  final bool isClosed;
  final String closedBy;
  final DateTime? closedAt;
  final double totalSales;
  final double totalCost;
  final double totalExpenses;
  final double totalProfit;

  DayStatusModel({
    required this.date,
    required this.isClosed,
    required this.closedBy,
    this.closedAt,
    required this.totalSales,
    required this.totalCost,
    required this.totalExpenses,
    required this.totalProfit,
  });

  factory DayStatusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DayStatusModel(
      date: doc.id,
      isClosed: data['isClosed'] ?? false,
      closedBy: data['closedBy'] ?? '',
      closedAt: (data['closedAt'] as Timestamp?)?.toDate(),
      totalSales: (data['totalSales'] ?? 0).toDouble(),
      totalCost: (data['totalCost'] ?? 0).toDouble(),
      totalExpenses: (data['totalExpenses'] ?? 0).toDouble(),
      totalProfit: (data['totalProfit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'isClosed': isClosed,
      'closedBy': closedBy,
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'totalSales': totalSales,
      'totalCost': totalCost,
      'totalExpenses': totalExpenses,
      'totalProfit': totalProfit,
    };
  }
}

// Summary report used for weekly/monthly aggregates
class PeriodReportModel {
  final String periodId; // weekId or monthId
  final double totalSales;
  final double totalCost;
  final double totalExpenses;
  final double totalProfit;
  final int totalTransactions;

  PeriodReportModel({
    required this.periodId,
    required this.totalSales,
    required this.totalCost,
    required this.totalExpenses,
    required this.totalProfit,
    required this.totalTransactions,
  });
}
