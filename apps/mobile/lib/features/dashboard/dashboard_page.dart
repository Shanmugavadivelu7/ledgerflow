import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../shared/widgets/app_error.dart';
import '../../shared/widgets/app_loading.dart';
import '../../core/utils/currency_formatter.dart';
import 'cubit/dashboard_cubit.dart';
import 'models/dashboard_stats.dart';
import 'repositories/dashboard_repository.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(DashboardRepository())..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().load(),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: const Color(0xFFF5F6FA),
                    floating: true,
                    titleSpacing: 20,
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey.shade500),
                              ),
                              Text(
                                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3949AB).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.store_outlined,
                            color: Color(0xFF3949AB),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    centerTitle: false,
                  ),
                  if (state is DashboardLoading || state is DashboardInitial)
                    const SliverFillRemaining(child: AppLoading()),
                  if (state is DashboardError)
                    SliverFillRemaining(
                      child: AppError(
                        message: state.message,
                        onRetry: () => context.read<DashboardCubit>().load(),
                      ),
                    ),
                  if (state is DashboardLoaded)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _TodayHeroCard(stats: state.stats),
                          const SizedBox(height: 16),
                          _SectionCard(
                            title: 'This Month',
                            icon: Icons.calendar_month_outlined,
                            children: [
                              _MetricRow(
                                label: 'Revenue',
                                value: CurrencyFormatter.format(
                                    state.stats.monthRevenue),
                                valueColor: const Color(0xFF3949AB),
                                bold: true,
                              ),
                              _RowDivider(),
                              _MetricRow(
                                label: 'Total Bills',
                                value: state.stats.monthBills.toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: 'All Time',
                            icon: Icons.insights_outlined,
                            children: [
                              _MetricRow(
                                label: 'Customers',
                                value: state.stats.overallCustomers.toString(),
                              ),
                              _RowDivider(),
                              _MetricRow(
                                label: 'Total Sales',
                                value: state.stats.overallSales.toString(),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TodayHeroCard extends StatelessWidget {
  final DashboardStats stats;
  const _TodayHeroCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF3949AB),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Today's Revenue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            CurrencyFormatter.format(stats.todayRevenue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${stats.todayBills} bill${stats.todayBills != 1 ? 's' : ''} recorded today',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Cash Collected',
                  value: CurrencyFormatter.format(stats.todayCash),
                  icon: Icons.payments_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Credit Given',
                  value: CurrencyFormatter.format(stats.todayCredit),
                  icon: Icons.account_balance_wallet_outlined,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool alignEnd;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: alignEnd ? 16 : 0, right: alignEnd ? 0 : 16),
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!alignEnd) ...[
                Icon(icon, color: Colors.white.withValues(alpha: 0.75), size: 13),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
              if (alignEnd) ...[
                const SizedBox(width: 5),
                Icon(icon, color: Colors.white.withValues(alpha: 0.75), size: 13),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey.shade100),
          ...children,
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _MetricRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.shade100,
    );
  }
}
