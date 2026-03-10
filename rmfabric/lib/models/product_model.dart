import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String name;
  final double sellingPrice;
  final double costPrice;
  final bool active;
  final DateTime createdAt;

  ProductModel({
    required this.productId,
    required this.name,
    required this.sellingPrice,
    required this.costPrice,
    required this.active,
    required this.createdAt,
  });

  double get margin => sellingPrice - costPrice;
  double get marginPercent =>
      sellingPrice > 0 ? (margin / sellingPrice) * 100 : 0;

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      productId: doc.id,
      name: data['name'] ?? '',
      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      active: data['active'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': name,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
