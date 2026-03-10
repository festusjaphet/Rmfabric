import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String expenseId;
  final String title;
  final String category;
  final double amount;
  final String note;
  final String createdBy; // userId of admin
  final String dayId;
  final String weekId;
  final String monthId;
  final DateTime createdAt;

  ExpenseModel({
    required this.expenseId,
    required this.title,
    required this.category,
    required this.amount,
    required this.note,
    required this.createdBy,
    required this.dayId,
    required this.weekId,
    required this.monthId,
    required this.createdAt,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      expenseId: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'Other',
      amount: (data['amount'] ?? 0).toDouble(),
      note: data['note'] ?? '',
      createdBy: data['createdBy'] ?? '',
      dayId: data['dayId'] ?? '',
      weekId: data['weekId'] ?? '',
      monthId: data['monthId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'expenseId': expenseId,
      'title': title,
      'category': category,
      'amount': amount,
      'note': note,
      'createdBy': createdBy,
      'dayId': dayId,
      'weekId': weekId,
      'monthId': monthId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
