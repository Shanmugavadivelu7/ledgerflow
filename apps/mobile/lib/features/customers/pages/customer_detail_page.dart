import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../features/sales/models/sale.dart';
import '../../../features/sales/repositories/sale_repository.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/customer.dart';
import '../../sales/pages/sale_detail_page.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late Future<List<Sale>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _salesFuture = SaleRepository().fetchByCustomer(widget.customer.id);
  }

  void _reload() {
    setState(() {
      _salesFuture = SaleRepository().fetchByCustomer(widget.customer.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: Text(widget.customer.name),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _CustomerHeader(customer: widget.customer),
          Expanded(
            child: FutureBuilder<List<Sale>>(
              future: _salesFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const AppLoading();
                }
                if (snap.hasError) {
                  return AppError(
                    message: snap.error.toString(),
                    onRetry: _reload,
                  );
                }
                final sales = snap.data ?? [];
                if (sales.isEmpty) {
                  return const EmptyState(
                    title: 'No sales yet',
                    subtitle: 'Sales for this customer will appear here.',
                    icon: Icons.receipt_long_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: sales.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _SaleRow(
                      sale: sales[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SaleDetailPage(saleId: sales[i].id),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  final Customer customer;
  const _CustomerHeader({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              customer.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                customer.phone ?? 'No phone number',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                'Since ${DateFormatter.date(customer.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  final Sale sale;
  final VoidCallback onTap;
  const _SaleRow({required this.sale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.dateTime(sale.createdAt),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sale.items.length} item${sale.items.length != 1 ? 's' : ''}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(sale.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(status: sale.paymentStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
