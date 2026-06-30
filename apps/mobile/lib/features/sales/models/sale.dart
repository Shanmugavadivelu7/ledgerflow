import 'package:equatable/equatable.dart';

import '../../customers/models/customer.dart';
import 'sale_item.dart';

class Sale extends Equatable {
  final String id;
  final String customerId;
  final double totalAmount;
  final String paymentStatus;
  final Customer customer;
  final List<SaleItem> items;
  final DateTime createdAt;

  const Sale({
    required this.id,
    required this.customerId,
    required this.totalAmount,
    required this.paymentStatus,
    required this.customer,
    required this.items,
    required this.createdAt,
  });

  bool get isPaid => paymentStatus == 'PAID';

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paymentStatus: json['paymentStatus'] as String,
        customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
        items: (json['items'] as List)
            .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [id, customerId, totalAmount, paymentStatus, customer, items, createdAt];
}
