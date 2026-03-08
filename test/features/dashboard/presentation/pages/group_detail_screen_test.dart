import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:splito_project/features/dashboard/presentation/pages/group_detail_screen.dart';
import 'package:splito_project/features/dashboard/presentation/pages/add_expense_screen.dart';
import 'package:splito_project/features/dashboard/presentation/view_models/group_detail_view_model.dart';
import 'package:splito_project/features/dashboard/domain/model/group_detail.dart';
import 'package:splito_project/features/dashboard/domain/model/group.dart';
import 'package:splito_project/features/dashboard/domain/model/balance.dart';
import 'package:splito_project/features/dashboard/domain/model/expense.dart';
import 'package:splito_project/features/dashboard/domain/model/settlement.dart';
import 'package:splito_project/features/dashboard/data/datasource/remote/group_remote_datasource.dart';
import 'package:splito_project/features/dashboard/data/datasource/remote/settlement_remote_datasource.dart';

// Mock GroupRemoteDataSource
class MockGroupRemoteDataSource implements GroupRemoteDataSource {
  GroupDetail? _groupDetail;
  bool _shouldThrow = false;
  String? _errorMessage;

  void setGroupDetail(GroupDetail detail) {
    _groupDetail = detail;
  }

  void setError(String message) {
    _shouldThrow = true;
    _errorMessage = message;
  }

  @override
  Future<GroupDetail> getGroupWithBalances(String groupId) async {
    if (_shouldThrow) {
      throw Exception(_errorMessage ?? 'Error');
    }
    if (_groupDetail == null) {
      throw Exception('No group detail set');
    }
    return _groupDetail!;
  }

  @override
  Future<List<Group>> getGroups() async {
    return [];
  }

  @override
  Future<Group> createGroup(String name, List<String> members) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteGroup(String groupId) async {}
}

// Mock SettlementRemoteDataSource
class MockSettlementRemoteDataSource implements SettlementRemoteDataSource {
  bool createSettlementCalled = false;
  String? lastFrom;
  String? lastTo;
  double? lastAmount;
  String? lastGroupId;

  @override
  Future<Settlement> createSettlement({
    required String from,
    required String to,
    required double amount,
    required String groupId,
  }) async {
    createSettlementCalled = true;
    lastFrom = from;
    lastTo = to;
    lastAmount = amount;
    lastGroupId = groupId;
    return Settlement(
      id: 's1',
      from: from,
      to: to,
      amount: amount,
      groupId: groupId,
      date: DateTime.now(),
    );
  }

  @override
  Future<List<Settlement>> getGroupSettlements(String groupId) async {
    return [];
  }

  @override
  Future<void> deleteSettlement(String settlementId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGroupRemoteDataSource mockGroupDataSource;
  late MockSettlementRemoteDataSource mockSettlementDataSource;
  late ProviderContainer container;

  final testGroup = Group(
    id: 'g1', 
    name: 'Trip to Goa', 
    members: ['Alice', 'Bob', 'Charlie'], 
    createdBy: 'user', 
    createdAt: DateTime.now()
  );
  
  final testBalances = [
    Balance(name: 'Alice', amount: 100),
    Balance(name: 'Bob', amount: -50),
    Balance(name: 'Charlie', amount: -50)
  ];
  
  final testExpenses = [
    Expense(
      id: 'e1',
      groupId: 'g1',
      description: 'Dinner',
      totalAmount: 60,
      date: DateTime(2025, 3, 1),
      payments: [
        Payment(name: 'Alice', amount: 60),
        Payment(name: 'Bob', amount: 0),
        Payment(name: 'Charlie', amount: 0)
      ],
      splits: [],
    )
  ];
  
  final testSettlements = [
    Settlement(
      id: 's1', 
      groupId: 'g1', 
      from: 'Bob', 
      to: 'Alice', 
      amount: 50, 
      date: DateTime(2025, 3, 2)
    )
  ];
  
  final testGroupDetail = GroupDetail(
    group: testGroup,
    balances: testBalances,
    expenses: testExpenses,
    settlements: testSettlements,
  );

  setUp(() {
    mockGroupDataSource = MockGroupRemoteDataSource();
    mockSettlementDataSource = MockSettlementRemoteDataSource();
    
    container = ProviderContainer(
      overrides: [
        groupRemoteDataSourceProvider.overrideWithValue(mockGroupDataSource),
        settlementRemoteDataSourceProvider.overrideWithValue(mockSettlementDataSource),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> pumpGroupDetailScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: GroupDetailScreen(groupId: 'g1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('2. error state shows error and retry', (tester) async {
    mockGroupDataSource.setError('fail');
    await pumpGroupDetailScreen(tester);

    expect(find.text('Error loading group'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
  });

  testWidgets('3. displays group name, members, expenses count', (tester) async {
    mockGroupDataSource.setGroupDetail(testGroupDetail);
    await pumpGroupDetailScreen(tester);
    
    expect(find.text('Trip to Goa'), findsOneWidget);
    expect(find.text('3 members'), findsOneWidget);
    expect(find.text('1 expenses'), findsOneWidget);
  });
  testWidgets('7. shows pie chart when expenses exist', (tester) async {
    mockGroupDataSource.setGroupDetail(testGroupDetail);
    await pumpGroupDetailScreen(tester);
    
    expect(find.byType(PieChart), findsOneWidget);
  });

  testWidgets('8. suggested settlements appear', (tester) async {
    mockGroupDataSource.setGroupDetail(testGroupDetail);
    await pumpGroupDetailScreen(tester);
    
    expect(find.text('💡 Suggested Settlements'), findsOneWidget);
  });

  testWidgets('10. add expense FAB exists', (tester) async {
    mockGroupDataSource.setGroupDetail(testGroupDetail);
    await pumpGroupDetailScreen(tester);
    
    expect(find.widgetWithText(FloatingActionButton, 'Add Expense'), findsOneWidget);
  });

  testWidgets('11. refresh button exists', (tester) async {
    mockGroupDataSource.setGroupDetail(testGroupDetail);
    await pumpGroupDetailScreen(tester);
    
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}