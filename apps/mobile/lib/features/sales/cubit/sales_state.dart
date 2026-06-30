import 'package:equatable/equatable.dart';
import '../models/sale.dart';

abstract class SalesState extends Equatable {
  const SalesState();
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {
  const SalesInitial();
}

class SalesLoading extends SalesState {
  const SalesLoading();
}

class SalesLoaded extends SalesState {
  final List<Sale> sales;
  const SalesLoaded(this.sales);
  @override
  List<Object?> get props => [sales];
}

class SalesError extends SalesState {
  final String message;
  const SalesError(this.message);
  @override
  List<Object?> get props => [message];
}
