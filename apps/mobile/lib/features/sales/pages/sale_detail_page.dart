import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/sale.dart';
import '../repositories/sale_repository.dart';

class SaleDetailPage extends StatefulWidget {
  final String saleId;
  const SaleDetailPage({super.key, required this.saleId});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  late Future<Sale> _future;

  @override
  void initState() {
    super.initState();
    _future = SaleRepository().fetchById(widget.saleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: const Text('Sale Details'),
        centerTitle: false,
      ),
      body: FutureBuilder<Sale>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          if (snap.hasError) {
            return AppError(
              message: snap.error.toString(),
              onRetry: () => setState(
                  () => _future = SaleRepository().fetchById(widget.saleId)),
            );
          }
          final sale = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoCard(sale: sale),
                const SizedBox(height: 16),
                _ItemsCard(sale: sale),
                const SizedBox(height: 16),
                _TotalCard(sale: sale),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Sale sale;
  const _InfoCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, 'Customer'),
          const SizedBox(height: 4),
          Text(sale.customer.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          if (sale.customer.phone != null) ...[
            const SizedBox(height: 2),
            Text(sale.customer.phone!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, 'Date'),
                    const SizedBox(height: 4),
                    Text(DateFormatter.dateTime(sale.createdAt),
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _label(context, 'Status'),
                  const SizedBox(height: 4),
                  StatusBadge(status: sale.paymentStatus),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final Sale sale;
  const _ItemsCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, 'Items'),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200))),
                children: [
                  _th('Product'),
                  _th('Qty'),
                  _th('Price'),
                  _th('Total', align: TextAlign.right),
                ],
              ),
              ...sale.items.map(
                (item) => TableRow(
                  children: [
                    _td(item.productName),
                    _td(item.quantity.toString()),
                    _td(CurrencyFormatter.format(item.unitPrice)),
                    _td(CurrencyFormatter.format(item.total),
                        align: TextAlign.right,
                        bold: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _th(String text, {TextAlign align = TextAlign.left}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            textAlign: align,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.4)),
      );

  Widget _td(String text,
          {TextAlign align = TextAlign.left, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            textAlign: align,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
      );
}

class _TotalCard extends StatelessWidget {
  final Sale sale;
  const _TotalCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            CurrencyFormatter.format(sale.totalAmount),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

Widget _label(BuildContext context, String text) => Text(
      text,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.4),
    );
