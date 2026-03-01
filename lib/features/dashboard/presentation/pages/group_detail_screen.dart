import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../view_models/group_detail_view_model.dart';
import '../view_models/add_expense_view_model.dart';
import '../view_models/all_expenses_view_model.dart';
import '../view_models/settlement_view_model.dart'; // You'll need to create this
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
      backgroundColor: const Color(0xFF0F1217),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171C24),
        elevation: 0,
        title: Text(
          'Group Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF22D3EE)),
            onPressed: () {
              ref.read(groupDetailViewModelProvider.notifier).loadGroupDetail(widget.groupId);
            },
          ),
        ],
      ),
      body: detailState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
        ),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Error loading group',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(groupDetailViewModelProvider.notifier).loadGroupDetail(widget.groupId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22D3EE),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return _buildContent(detail);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
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
            ref.read(groupDetailViewModelProvider.notifier).loadGroupDetail(widget.groupId);
          });
        },
        backgroundColor: const Color(0xFF22D3EE),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(GroupDetail detail) {
    return CustomScrollView(
      slivers: [
        // Group Header Sliver
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF22D3EE).withOpacity(0.2),
                  const Color(0xFF0F1217),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22D3EE).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people, color: Color(0xFF22D3EE), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${detail.group.members.length} members',
                            style: const TextStyle(color: Color(0xFF22D3EE)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (detail.expenses.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.receipt, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${detail.expenses.length} expenses',
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Chart Section
        if (detail.expenses.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF171C24),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pie_chart, color: Color(0xFF22D3EE), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Payment Distribution',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: _buildEnhancedPieChart(detail),
                  ),
                ],
              ),
            ),
          ),

        // Balances Section with Settle Up Button
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF171C24),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Color(0xFF22D3EE), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Balances',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showSettleUpModal(detail),
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      label: const Text(
                        'Settle Up',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22D3EE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...detail.balances.map((b) => _buildBalanceItem(b)),
                
                // Suggested settlements
                if (_getSuggestedSettlements(detail.balances).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF2A3344)),
                  const SizedBox(height: 16),
                  const Text(
                    '💡 Suggested Settlements',
                    style: TextStyle(
                      color: Color(0xFF22D3EE),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._getSuggestedSettlements(detail.balances).map((suggestion) => 
                    _buildSuggestionItem(suggestion, detail.group.members),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Expenses Section
        if (detail.expenses.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF171C24),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt, color: Color(0xFF22D3EE), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Recent Expenses',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...detail.expenses.take(5).map((e) => _buildExpenseItem(e)),
                  if (detail.expenses.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Center(
                        child: Text(
                          '+ ${detail.expenses.length - 5} more expenses',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Settlements Section
        if (detail.settlements.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF171C24),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.swap_horiz, color: Color(0xFF22D3EE), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Settlement History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...detail.settlements.map((s) => _buildSettlementItem(s)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showSettleUpModal(GroupDetail detail) {
    String selectedFrom = detail.group.members.first;
    String selectedTo = detail.group.members.length > 1 ? detail.group.members[1] : detail.group.members.first;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F2630),
        title: const Text(
          'Record Settlement',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // From dropdown
                DropdownButtonFormField<String>(
                  value: selectedFrom,
                  dropdownColor: const Color(0xFF171C24),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Who is paying?',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2A3344)),
                    ),
                  ),
                  items: detail.group.members.map((member) {
                    return DropdownMenuItem(
                      value: member,
                      child: Text(member, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedFrom = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // To dropdown
                DropdownButtonFormField<String>(
                  value: selectedTo,
                  dropdownColor: const Color(0xFF171C24),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Who is receiving?',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2A3344)),
                    ),
                  ),
                  items: detail.group.members.map((member) {
                    return DropdownMenuItem(
                      value: member,
                      child: Text(member, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedTo = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Amount input
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixText: 'Rs ',
                    prefixStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2A3344)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }
              
              if (selectedFrom == selectedTo) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot settle with yourself')),
                );
                return;
              }

              Navigator.pop(ctx);
              
              try {
  await ref.read(settlementViewModelProvider).createSettlement(
    from: selectedFrom,
    to: selectedTo,
    amount: amount,
    groupId: widget.groupId,
  );
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('✓ Settlement recorded: $selectedFrom paid $selectedTo Rs $amount'),
      backgroundColor: Colors.green,
    ),
  );
  
  // Refresh data
  ref.read(groupDetailViewModelProvider.notifier).loadGroupDetail(widget.groupId);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to record settlement: $e')),
  );
}
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22D3EE),
              foregroundColor: Colors.white,
            ),
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSuggestedSettlements(List<Balance> balances) {
  final debtors = balances
      .where((b) => b.amount < -0.01)
      .map((b) => {'name': b.name, 'amount': b.amount.abs()})
      .toList();
  
  // Safe sorting with null checks
  debtors.sort((a, b) {
    final aAmount = a['amount'] as double? ?? 0;
    final bAmount = b['amount'] as double? ?? 0;
    return bAmount.compareTo(aAmount);
  });
  
  final creditors = balances
      .where((b) => b.amount > 0.01)
      .map((b) => {'name': b.name, 'amount': b.amount})
      .toList();
  
  // Safe sorting with null checks
  creditors.sort((a, b) {
    final aAmount = a['amount'] as double? ?? 0;
    final bAmount = b['amount'] as double? ?? 0;
    return bAmount.compareTo(aAmount);
  });

  if (debtors.isEmpty || creditors.isEmpty) return [];

  final suggestions = <Map<String, dynamic>>[];
  int i = 0, j = 0;

  while (i < debtors.length && j < creditors.length) {
    final debtor = debtors[i];
    final creditor = creditors[j];
    
    final debtorAmount = debtor['amount'] as double? ?? 0;
    final creditorAmount = creditor['amount'] as double? ?? 0;
    
    final amount = debtorAmount < creditorAmount ? debtorAmount : creditorAmount;
    
    if (amount > 0.01) {
      suggestions.add({
        'from': debtor['name'],
        'to': creditor['name'],
        'amount': amount,
      });
    }

    debtor['amount'] = debtorAmount - amount;
    creditor['amount'] = creditorAmount - amount;

    if ((debtor['amount'] as double? ?? 0) < 0.01) i++;
    if ((creditor['amount'] as double? ?? 0) < 0.01) j++;
  }

  return suggestions;
}

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion, List<String> members) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2630),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3344)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${suggestion['from']} → ${suggestion['to']}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            'Rs ${suggestion['amount'].toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF22D3EE),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPieChart(GroupDetail detail) {
    // Aggregate payments per member
    final Map<String, double> paymentTotals = {};
    for (var exp in detail.expenses) {
      for (var payment in exp.payments) {
        paymentTotals[payment.name] = (paymentTotals[payment.name] ?? 0) + payment.amount;
      }
    }

    if (paymentTotals.isEmpty) {
      return const Center(
        child: Text(
          'No payment data',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final colors = [
      const Color(0xFF22D3EE), // Cyan
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF10B981), // Green
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
    ];

    final entries = paymentTotals.entries.toList();
    final total = paymentTotals.values.fold(0.0, (a, b) => a + b);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        startDegreeOffset: 180,
        sections: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final percentage = (data.value / total * 100).toStringAsFixed(1);
          
          return PieChartSectionData(
            value: data.value,
            title: '${data.key}\n$percentage%',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            radius: 80,
            color: colors[index % colors.length],
            titlePositionPercentageOffset: 0.6,
            borderSide: const BorderSide(color: Colors.transparent),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBalanceItem(Balance balance) {
    final isPositive = balance.amount > 0;
    final isNegative = balance.amount < 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2630),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPositive 
              ? Colors.green.withOpacity(0.3) 
              : isNegative 
                  ? Colors.red.withOpacity(0.3) 
                  : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPositive 
                  ? Colors.green.withOpacity(0.2)
                  : isNegative
                      ? Colors.red.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
            ),
            child: Icon(
              isPositive 
                  ? Icons.arrow_upward
                  : isNegative
                      ? Icons.arrow_downward
                      : Icons.horizontal_rule,
              color: isPositive 
                  ? Colors.green
                  : isNegative
                      ? Colors.red
                      : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              balance.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}Rs ${balance.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: isPositive 
                  ? Colors.green
                  : isNegative
                      ? Colors.red
                      : Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2630),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  expense.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22D3EE).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Rs ${expense.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF22D3EE),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _confirmDeleteExpense(context, expense.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: expense.payments.map((p) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${p.name}: Rs ${p.amount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            )).toList(),
          ),
          const SizedBox(height: 4),
          Text(
            '${expense.date.day}/${expense.date.month}/${expense.date.year}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExpense(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(deleteExpenseProvider)(expenseId);
                // Refresh group detail
                ref.read(groupDetailViewModelProvider.notifier).loadGroupDetail(widget.groupId);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete expense: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementItem(Settlement settlement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2630),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22D3EE).withOpacity(0.2),
            ),
            child: const Icon(
              Icons.swap_horiz,
              color: Color(0xFF22D3EE),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${settlement.from} → ${settlement.to}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${settlement.date.day}/${settlement.date.month}/${settlement.date.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Rs ${settlement.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}