class Balance {
  final String name;
  final double amount;
  Balance({required this.name, required this.amount});
  factory Balance.fromJson(Map<String, dynamic> json) =>
      Balance(name: json['name'] ?? '', amount: (json['amount'] ?? 0).toDouble());
}