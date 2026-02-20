import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../view_models/group_detail_view_model.dart';
import '../view_models/add_expense_view_model.dart';
import 'add_expense_screen.dart';
import '../../domain/model/group_detail.dart';
import '../../domain/model/balance.dart';
import '../../domain/model/expense.dart';
import '../../domain/model/settlement.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(groupDetailViewModelProvider.notifier).loadGroupDetail(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(groupDetailViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Group Details')),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (detail) {
          if (detail == null) return const Center(child: Text('No data'));
          return _buildContent(detail);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final currentDetail = detailState.value;
          if (currentDetail == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(
                groupId: widget.groupId,
                members: currentDetail.group.members,
              ),
            ),
          ).then((_) {
            // Refresh after returning
            ref.read(groupDetailViewModelProvider.notifier).loadGroupDetail(widget.groupId);
          });
        },
      ),
    );
  }

  Widget _buildContent(GroupDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.group.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          if (detail.expenses.isNotEmpty) _buildCharts(detail),
          const SizedBox(height: 20),
          _buildBalances(detail.balances),
          const SizedBox(height: 20),
          _buildExpenses(detail.expenses),
          const SizedBox(height: 20),
          if (detail.settlements.isNotEmpty) _buildSettlements(detail.settlements),
        ],
      ),
    );
  }

  Widget _buildCharts(GroupDetail detail) {
    // Aggregate payments per member
    final Map<String, double> paymentTotals = {};
    for (var exp in detail.expenses) {
      for (var payment in exp.payments) {
        paymentTotals[payment.name] = (paymentTotals[payment.name] ?? 0) + payment.amount;
      }
    }

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text('Payments', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sections: paymentTotals.entries.map((e) {
                          return PieChartSectionData(
                            value: e.value,
                            title: e.key,
                            color: Colors.primaries[e.key.hashCode % Colors.primaries.length],
                            radius: 50,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text('Balances', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: BarChart(
                      BarChartData(
                        barGroups: detail.balances.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.amount.abs(),
                                color: entry.value.amount > 0 ? Colors.green : Colors.red,
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < detail.balances.length) {
                                  return Text(detail.balances[value.toInt()].name);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalances(List<Balance> balances) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Balances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...balances.map((b) => ListTile(
              title: Text(b.name),
              trailing: Text(
                '${b.amount > 0 ? '+' : '-'}Rs ${b.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: b.amount > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenses(List<Expense> expenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...expenses.map((e) => ListTile(
              title: Text(e.description),
              subtitle: Text('Paid by: ${e.payments.map((p) => p.name).join(', ')}'),
              trailing: Text('Rs ${e.totalAmount.toStringAsFixed(2)}'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlements(List<Settlement> settlements) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settlements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...settlements.map((s) => ListTile(
              title: Text('${s.from} → ${s.to}'),
              trailing: Text('Rs ${s.amount.toStringAsFixed(2)}'),
            )),
          ],
        ),
      ),
    );
  }
}