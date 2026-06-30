import 'package:equatable/equatable.dart';

import '../../customers/models/customer.dart';

class Report extends Equatable {
  final String type;
  final double revenue;
  final int bills;
  final double cash;
  final double credit;
  final Customer? customer;
  final int? billCount;

  const Report({
    required this.type,
    required this.revenue,
    required this.bills,
    required this.cash,
    required this.credit,
    this.customer,
    this.billCount,
  });

  factory Report.fromJson(Map<String, dynamic> json, String type) {
    if (type == 'customer') {
      return Report(
        type: type,
        revenue: (json['revenue'] as num).toDouble(),
        bills: 0,
        cash: (json['cash'] as num).toDouble(),
        credit: (json['credit'] as num).toDouble(),
        customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
        billCount: (json['billCount'] as num).toInt(),
      );
    }
    return Report(
      type: type,
      revenue: (json['revenue'] as num).toDouble(),
      bills: (json['bills'] as num).toInt(),
      cash: (json['cash'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [type, revenue, bills, cash, credit, customer, billCount];
}
