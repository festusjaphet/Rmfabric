import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  final String saleId;
  final String productId;
  final String productName;
  final int quantity;
  final double sellingPrice;
  final double costPrice;
  final double totalSale;
  final double totalCost;
  final double profit;
  final String sellerId;
  final String sellerName;
  final String paymentMethod;
  final String dayId;
  final String weekId;
  final String monthId;
  final DateTime createdAt;

  SaleModel({
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.sellingPrice,
    required this.costPrice,
    required this.totalSale,
    required this.totalCost,
    required this.profit,
    required this.sellerId,
    required this.sellerName,
    required this.paymentMethod,
    required this.dayId,
    required this.weekId,
    required this.monthId,
    required this.createdAt,
  });

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleModel(
      saleId: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantity: (data['quantity'] ?? 1).toInt(),
      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      totalSale: (data['totalSale'] ?? 0).toDouble(),
      totalCost: (data['totalCost'] ?? 0).toDouble(),
      profit: (data['profit'] ?? 0).toDouble(),
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      paymentMethod: data['paymentMethod'] ?? 'Cash',
      dayId: data['dayId'] ?? '',
      weekId: data['weekId'] ?? '',
      monthId: data['monthId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'saleId': saleId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'totalSale': totalSale,
      'totalCost': totalCost,
      'profit': profit,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'paymentMethod': paymentMethod,
      'dayId': dayId,
      'weekId': weekId,
      'monthId': monthId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
