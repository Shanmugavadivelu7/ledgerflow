import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final double todayRevenue;
  final int todayBills;
  final double todayCash;
  final double todayCredit;
  final double monthRevenue;
  final int monthBills;
  final int overallCustomers;
  final int overallSales;

  const DashboardStats({
    required this.todayRevenue,
    required this.todayBills,
    required this.todayCash,
    required this.todayCredit,
    required this.monthRevenue,
    required this.monthBills,
    required this.overallCustomers,
    required this.overallSales,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final today = json['today'] as Map<String, dynamic>;
    final month = json['month'] as Map<String, dynamic>;
    final overall = json['overall'] as Map<String, dynamic>;
    return DashboardStats(
      todayRevenue: (today['revenue'] as num).toDouble(),
      todayBills: (today['bills'] as num).toInt(),
      todayCash: (today['cash'] as num).toDouble(),
      todayCredit: (today['credit'] as num).toDouble(),
      monthRevenue: (month['revenue'] as num).toDouble(),
      monthBills: (month['bills'] as num).toInt(),
      overallCustomers: (overall['customers'] as num).toInt(),
      overallSales: (overall['sales'] as num).toInt(),
    );
  }

  @override
  List<Object?> get props => [
        todayRevenue, todayBills, todayCash, todayCredit,
        monthRevenue, monthBills, overallCustomers, overallSales,
      ];
}
