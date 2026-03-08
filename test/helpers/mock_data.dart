import 'package:splito_project/features/dashboard/domain/model/group.dart';
import 'package:splito_project/features/dashboard/domain/model/balance.dart';
import 'package:splito_project/features/dashboard/domain/model/expense.dart';
import 'package:splito_project/features/dashboard/domain/model/settlement.dart';
import 'package:splito_project/features/dashboard/domain/model/group_detail.dart';
import 'package:splito_project/features/dashboard/domain/model/user.dart';

class MockData {
  static final testGroup = Group(
    id: 'g1',
    name: 'Trip to Goa',
    members: ['Alice', 'Bob', 'Charlie'],
    createdBy: 'user1',
    createdAt: DateTime.now(),
  );

  static final testGroups = [
    Group(id: 'g1', name: 'Trip to Goa', members: ['Alice', 'Bob'], createdBy: 'user', createdAt: DateTime.now()),
    Group(id: 'g2', name: 'Dinner Club', members: ['Charlie', 'David'], createdBy: 'user', createdAt: DateTime.now()),
  ];

  static final testBalances = [
    Balance(name: 'Alice', amount: 100),
    Balance(name: 'Bob', amount: -50),
    Balance(name: 'Charlie', amount: -50),
  ];

  static final testExpenses = [
    Expense(
      id: 'e1',
      groupId: 'g1',
      description: 'Dinner',
      totalAmount: 60,
      date: DateTime(2025, 3, 1),
      payments: [
        Payment(name: 'Alice', amount: 60),
        Payment(name: 'Bob', amount: 0),
        Payment(name: 'Charlie', amount: 0),
      ],
      splits: [],
    ),
  ];

  static final testSettlements = [
    Settlement(
      id: 's1',
      groupId: 'g1',
      from: 'Bob',
      to: 'Alice',
      amount: 50,
      date: DateTime(2025, 3, 2),
    ),
  ];

  static final testGroupDetail = GroupDetail(
    group: testGroup,
    balances: testBalances,
    expenses: testExpenses,
    settlements: testSettlements,
  );

  static final testUser = User(
    id: 'u1',
    username: 'john_doe',
    email: 'john@example.com',
    profileImage: 'http://example.com/image.jpg',
  );
}