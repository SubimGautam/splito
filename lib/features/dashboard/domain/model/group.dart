class Group {
  final String id;
  final String name;
  final List<String> members;
  final String createdBy;
  final DateTime createdAt;
  final double totalBalance;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.createdBy,
    required this.createdAt,
    this.totalBalance = 0.0,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'totalBalance': totalBalance,
    };
  }
}