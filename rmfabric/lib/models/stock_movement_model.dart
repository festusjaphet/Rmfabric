import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents stockqty adjustments: sale deductions, manual restocking
class StockMovementModel {
  final String movementId;
  final String productId;
  final String productName;
  final double quantityChange; // negative for deductions, positive for restocks
  final String reason; // 'sale', 'restock', 'adjustment', 'return'
  final String createdBy; // userId
  final DateTime createdAt;

  StockMovementModel({
    required this.movementId,
    required this.productId,
    required this.productName,
    required this.quantityChange,
    required this.reason,
    required this.createdBy,
    required this.createdAt,
  });

  factory StockMovementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockMovementModel(
      movementId: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantityChange: (data['quantityChange'] ?? 0).toDouble(),
      reason: data['reason'] ?? 'adjustment',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'movementId': movementId,
      'productId': productId,
      'productName': productName,
      'quantityChange': quantityChange,
      'reason': reason,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
