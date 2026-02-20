class Expense {
  final String id;
  final String description;
  final double totalAmount;
  final DateTime date;
  final String groupId;
  final List<Payment> payments;
  final List<Split> splits;

  Expense({
    required this.id,
    required this.description,
    required this.totalAmount,
    required this.date,
    required this.groupId,
    required this.payments,
    required this.splits,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'] ?? json['id'] ?? '',
      description: json['description'] ?? '',
      totalAmount: (json['totalAmount'] ?? json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      groupId: json['group'] ?? json['groupId'] ?? '',
      payments: (json['payments'] as List?)?.map((e) => Payment.fromJson(e)).toList() ?? [],
      splits: (json['splits'] as List?)?.map((e) => Split.fromJson(e)).toList() ?? [],
    );
  }
}

class Payment {
  final String name;
  final double amount;
  Payment({required this.name, required this.amount});
  factory Payment.fromJson(Map<String, dynamic> json) =>
      Payment(name: json['name'] ?? '', amount: (json['amount'] ?? 0).toDouble());
}

class Split {
  final String name;
  final double amount;
  Split({required this.name, required this.amount});
  factory Split.fromJson(Map<String, dynamic> json) =>
      Split(name: json['name'] ?? '', amount: (json['amount'] ?? 0).toDouble());
}