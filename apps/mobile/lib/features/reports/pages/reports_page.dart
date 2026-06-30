import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../features/customers/models/customer.dart';
import '../../../features/customers/repositories/customer_repository.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';
import '../cubit/report_cubit.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportCubit(ReportRepository()),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  String _type = 'daily';
  Customer? _selectedCustomer;
  List<Customer> _customers = [];
  bool _loadingCustomers = false;

  final _types = const ['daily', 'monthly', 'yearly', 'customer'];
  final _labels = const ['Daily', 'Monthly', 'Yearly', 'By Customer'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<ReportCubit>().load(
          type: _type,
          customerId: _type == 'customer' ? _selectedCustomer?.id : null,
        );
  }

  Future<void> _loadCustomers() async {
    if (_customers.isNotEmpty) return;
    setState(() => _loadingCustomers = true);
    try {
      final list = await CustomerRepository().fetchAll();
      if (mounted) setState(() { _customers = list; _loadingCustomers = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCustomers = false);
    }
  }

  Future<void> _pickCustomer() async {
    if (_loadingCustomers) return;
    final picked = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CustomerPickerSheet(
        customers: _customers,
        selected: _selectedCustomer,
      ),
    );
    if (picked != null) {
      setState(() => _selectedCustomer = picked);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        title: const Text('Reports'),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_types.length, (i) {
                  final selected = _type == _types[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_labels[i]),
                      selected: selected,
                      onSelected: (_) async {
                        setState(() {
                          _type = _types[i];
                          _selectedCustomer = null;
                        });
                        if (_types[i] == 'customer') await _loadCustomers();
                        _load();
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          if (_type == 'customer')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _loadingCustomers
                  ? const LinearProgressIndicator()
                  : GestureDetector(
                      onTap: _pickCustomer,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedCustomer?.name ?? 'Select a customer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedCustomer != null
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.expand_more,
                                color: Colors.grey.shade500, size: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          Expanded(
            child: BlocBuilder<ReportCubit, ReportState>(
              builder: (context, state) {
                if (state is ReportInitial) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bar_chart_rounded,
                              size: 36, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _type == 'customer'
                              ? 'Select a customer above'
                              : 'Loading report...',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _type == 'customer'
                              ? 'Their sales summary will appear here'
                              : 'Please wait',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ReportLoading) return const AppLoading();
                if (state is ReportError) {
                  return AppError(message: state.message, onRetry: _load);
                }
                if (state is ReportLoaded) {
                  return _ReportContent(report: state.report);
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerPickerSheet extends StatefulWidget {
  final List<Customer> customers;
  final Customer? selected;
  const _CustomerPickerSheet({required this.customers, this.selected});

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.customers
        : widget.customers
            .where((c) =>
                c.name.toLowerCase().contains(_query.toLowerCase()) ||
                (c.phone ?? '').contains(_query))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text(
                  'Select Customer',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No customers found',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    controller: controller,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      final isSelected = widget.selected?.id == c.id;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF3949AB)
                              .withValues(alpha: 0.1),
                          child: Text(
                            c.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF3949AB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(c.name,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: c.phone != null ? Text(c.phone!) : null,
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF3949AB))
                            : null,
                        onTap: () => Navigator.pop(context, c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  final Report report;
  const _ReportContent({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.customer != null) ...[
            _CustomerHeader(customer: report.customer!),
            const SizedBox(height: 16),
          ],
          _RevenueHero(revenue: report.revenue),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.payments_outlined,
                  label: 'Cash',
                  value: CurrencyFormatter.format(report.cash),
                  iconColor: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Credit',
                  value: CurrencyFormatter.format(report.credit),
                  iconColor: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MetricCard(
            icon: Icons.receipt_long_outlined,
            label: report.type == 'customer' ? 'Total Bills' : 'Total Bills',
            value: (report.type == 'customer'
                    ? report.billCount
                    : report.bills)
                .toString(),
            iconColor: Colors.teal.shade600,
          ),
        ],
      ),
    );
  }
}

class _RevenueHero extends StatelessWidget {
  final double revenue;
  const _RevenueHero({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3949AB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Revenue',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(revenue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                const Color(0xFF3949AB).withValues(alpha: 0.1),
            child: Text(
              customer.name[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF3949AB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                if (customer.phone != null)
                  Text(customer.phone!,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
