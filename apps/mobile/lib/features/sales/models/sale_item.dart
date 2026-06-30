import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;

  const SaleItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
        id: json['id'] as String,
        productName: json['productName'] as String,
        quantity: (json['quantity'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  @override
  List<Object?> get props => [id, productName, quantity, unitPrice];
}
