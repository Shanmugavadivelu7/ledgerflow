import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../features/customers/models/customer.dart';
import '../../../features/customers/repositories/customer_repository.dart';
import '../../../features/sales/repositories/sale_repository.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/sale_item.dart';

class CreateSalePage extends StatefulWidget {
  const CreateSalePage({super.key});

  @override
  State<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends State<CreateSalePage> {
  final _form = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  String _paymentStatus = 'PAID';
  final List<_ItemRow> _items = [_ItemRow()];
  List<Customer> _customers = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    CustomerRepository().fetchAll().then((list) {
      if (mounted) setState(() => _customers = list);
    }).catchError((_) {});
  }

  double get _total => _items.fold(0.0, (sum, row) => sum + row.lineTotal);

  Future<void> _pickCustomer() async {
    final result = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CustomerPickerSheet(
        customers: _customers,
        selected: _selectedCustomer,
      ),
    );
    if (result != null) setState(() => _selectedCustomer = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: const Text('New Sale'),
        centerTitle: false,
      ),
      body: Form(
        key: _form,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Customer'),
                    const SizedBox(height: 8),
                    _CustomerField(
                      customer: _selectedCustomer,
                      onTap: _pickCustomer,
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel('Payment'),
                    const SizedBox(height: 8),
                    _PaymentToggle(
                      value: _paymentStatus,
                      onChanged: (v) => setState(() => _paymentStatus = v),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _sectionLabel('Items'),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _items.add(_ItemRow())),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._items.asMap().entries.map(
                          (e) => _ItemCard(
                            key: ValueKey(e.key),
                            row: e.value,
                            canRemove: _items.length > 1,
                            onChanged: () => setState(() {}),
                            onRemove: () =>
                                setState(() => _items.removeAt(e.key)),
                          ),
                        ),
                    const SizedBox(height: 16),
                    _TotalRow(total: _total),
                  ],
                ),
              ),
            ),
            _SubmitBar(
              total: _total,
              loading: _submitting,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.4,
        ),
      );

  Future<void> _submit() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (!_form.currentState!.validate()) return;
    if (_total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final items = _items
          .map((r) => SaleItem(
                id: '',
                productName: r.nameCtrl.text.trim(),
                quantity: int.tryParse(r.qtyCtrl.text) ?? 1,
                unitPrice: double.tryParse(r.priceCtrl.text) ?? 0,
              ))
          .toList();

      await SaleRepository().create(
        customerId: _selectedCustomer!.id,
        paymentStatus: _paymentStatus,
        items: items,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale recorded successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    for (final r in _items) r.dispose();
    super.dispose();
  }
}

// ─── Customer field (tappable, not a dropdown) ────────────────────────────────

class _CustomerField extends StatelessWidget {
  final Customer? customer;
  final VoidCallback onTap;

  const _CustomerField({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: customer != null
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
          ),
        ),
        child: Row(
          children: [
            if (customer != null) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                child: Text(
                  customer!.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer!.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (customer!.phone != null)
                      Text(
                        customer!.phone!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Icon(Icons.swap_horiz,
                    color: Colors.grey.shade500, size: 20),
              ),
            ] else ...[
              Icon(Icons.person_search_outlined,
                  color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tap to select customer',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Customer picker bottom sheet ─────────────────────────────────────────────

class _CustomerPickerSheet extends StatefulWidget {
  final List<Customer> customers;
  final Customer? selected;

  const _CustomerPickerSheet({required this.customers, this.selected});

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Customer> get _filtered {
    if (_query.isEmpty) return widget.customers;
    return widget.customers
        .where((c) =>
            c.name.toLowerCase().contains(_query) ||
            (c.phone ?? '').contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Column(
        children: [
          // handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
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
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _search,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
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
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty
                          ? 'No customers yet. Add one first.'
                          : 'No match for "$_query"',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      final isSelected = widget.selected?.id == c.id;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          child: Text(
                            c.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(c.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        subtitle: c.phone != null
                            ? Text(c.phone!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600))
                            : null,
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary)
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

// ─── Item row data ────────────────────────────────────────────────────────────

class _ItemRow {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();

  double get lineTotal {
    final qty = int.tryParse(qtyCtrl.text) ?? 0;
    final price = double.tryParse(priceCtrl.text) ?? 0;
    return qty * price;
  }

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }
}

// ─── Item card ────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final _ItemRow row;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _ItemCard({
    super.key,
    required this.row,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          AppTextField(
            label: 'Product Name',
            controller: row.nameCtrl,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Qty',
                  controller: row.qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => onChanged(),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n < 1) ? 'Min 1' : null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: 'Unit Price (₹)',
                  controller: row.priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (_) => onChanged(),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return (n == null || n <= 0) ? 'Must be > 0' : null;
                  },
                ),
              ),
            ],
          ),
          if (canRemove) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Remove'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Payment toggle ───────────────────────────────────────────────────────────

class _PaymentToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PaymentToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
            value: 'PAID',
            label: Text('Paid'),
            icon: Icon(Icons.check_circle_outline)),
        ButtonSegment(
            value: 'CREDIT',
            label: Text('Credit'),
            icon: Icon(Icons.schedule)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// ─── Total row ────────────────────────────────────────────────────────────────

class _TotalRow extends StatelessWidget {
  final double total;
  const _TotalRow({required this.total});

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Subtotal',
              style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
            CurrencyFormatter.format(total),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ─── Submit bar ───────────────────────────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  final double total;
  final bool loading;
  final VoidCallback onSubmit;

  const _SubmitBar({
    required this.total,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total',
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(
                CurrencyFormatter.format(total),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Sale',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
