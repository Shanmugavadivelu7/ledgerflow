import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/status_badge.dart';
import '../cubit/sales_cubit.dart';
import '../models/sale.dart';
import '../repositories/sale_repository.dart';
import 'create_sale_page.dart';
import 'sale_detail_page.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalesCubit(SaleRepository())..loadToday(),
      child: const _SalesView(),
    );
  }
}

class _SalesView extends StatefulWidget {
  const _SalesView();

  @override
  State<_SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<_SalesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      final cubit = context.read<SalesCubit>();
      if (_tabs.index == 0) {
        cubit.loadToday();
      } else {
        cubit.loadAll();
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: const Text('Sales'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: "Today"),
            Tab(text: "All"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final cubit = context.read<SalesCubit>();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateSalePage()),
          );
          if (_tabs.index == 0) {
            cubit.loadToday();
          } else {
            cubit.loadAll();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Sale'),
      ),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading || state is SalesInitial) return const AppLoading();
          if (state is SalesError) {
            return AppError(
              message: state.message,
              onRetry: () {
                final cubit = context.read<SalesCubit>();
                _tabs.index == 0 ? cubit.loadToday() : cubit.loadAll();
              },
            );
          }
          if (state is SalesLoaded) {
            if (state.sales.isEmpty) {
              return EmptyState(
                title: _tabs.index == 0 ? 'No sales today' : 'No sales yet',
                subtitle: 'Tap the button below to record a new sale.',
                icon: Icons.receipt_long_outlined,
              );
            }
            return RefreshIndicator(
              onRefresh: () {
                final cubit = context.read<SalesCubit>();
                return _tabs.index == 0 ? cubit.loadToday() : cubit.loadAll();
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: state.sales.length,
                separatorBuilder: (_, i) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _SaleCard(
                  sale: state.sales[i],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SaleDetailPage(saleId: state.sales[i].id),
                      ),
                    );
                    final cubit = context.read<SalesCubit>();
                    _tabs.index == 0 ? cubit.loadToday() : cubit.loadAll();
                  },
                  onDelete: () => context
                      .read<SalesCubit>()
                      .delete(state.sales[i].id),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SaleCard({
    required this.sale,
    required this.onTap,
    required this.onDelete,
  });

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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    sale.customer.name[0].toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.customer.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sale.items.length} item${sale.items.length != 1 ? 's' : ''} · ${DateFormatter.dateTime(sale.createdAt)}',
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
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') {
                    _confirmDelete(context);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
                icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text('Are you sure you want to delete this sale? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
