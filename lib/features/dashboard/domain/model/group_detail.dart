import 'group.dart';
import 'expense.dart';
import 'settlement.dart';
import 'balance.dart';

class GroupDetail {
  final Group group;
  final List<Expense> expenses;
  final List<Settlement> settlements;
  final List<Balance> balances;

  GroupDetail({
    required this.group,
    required this.expenses,
    required this.settlements,
    required this.balances,
  });

  factory GroupDetail.fromJson(Map<String, dynamic> json) {
    return GroupDetail(
      group: Group.fromJson(json['group'] ?? {}),
      expenses: (json['expenses'] as List?)?.map((e) => Expense.fromJson(e)).toList() ?? [],
      settlements: (json['settlements'] as List?)?.map((s) => Settlement.fromJson(s)).toList() ?? [],
      balances: (json['balances'] as List?)?.map((b) => Balance.fromJson(b)).toList() ?? [],
    );
  }
}