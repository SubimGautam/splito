class Settlement {
  final String id;
  final String from;
  final String to;
  final double amount;
  final DateTime date;
  final String groupId;

  Settlement({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.date,
    required this.groupId,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['_id'] ?? json['id'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      groupId: json['group'] ?? json['groupId'] ?? '',
    );
  }
}