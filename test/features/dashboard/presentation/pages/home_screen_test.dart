import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splito_project/features/dashboard/domain/model/group_detail.dart';
import 'package:splito_project/features/dashboard/presentation/pages/home_screen.dart';
import 'package:splito_project/features/dashboard/presentation/pages/group_detail_screen.dart';
import 'package:splito_project/features/dashboard/presentation/view_models/groups_view_model.dart';
import 'package:splito_project/features/dashboard/domain/model/group.dart';
import 'package:splito_project/features/dashboard/data/datasource/remote/group_remote_datasource.dart';

// Mock the data source instead of the ViewModel
class MockGroupRemoteDataSource implements GroupRemoteDataSource {
  List<Group> _groups = [];
  bool _shouldThrow = false;
  String? _errorMessage;

  void setGroups(List<Group> groups) {
    _groups = groups;
  }

  void setError(String message) {
    _shouldThrow = true;
    _errorMessage = message;
  }

  @override
  Future<List<Group>> getGroups() async {
    if (_shouldThrow) {
      throw Exception(_errorMessage ?? 'Error');
    }
    return _groups;
  }

  @override
  Future<Group> createGroup(String name, List<String> members) async {
    return Group(
      id: 'new',
      name: name,
      members: members,
      createdBy: 'user',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<GroupDetail> getGroupWithBalances(String groupId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteGroup(String groupId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGroupRemoteDataSource mockDataSource;
  late ProviderContainer container;

  final testGroups = [
    Group(id: 'g1', name: 'Trip to Goa', members: ['Alice', 'Bob'], createdBy: 'user', createdAt: DateTime.now()),
    Group(id: 'g2', name: 'Dinner Club', members: ['Charlie', 'David'], createdBy: 'user', createdAt: DateTime.now()),
  ];

  setUp(() {
    mockDataSource = MockGroupRemoteDataSource();
    
    // Override the data source provider, not the ViewModel provider
    container = ProviderContainer(
      overrides: [
        groupRemoteDataSourceProvider.overrideWithValue(mockDataSource),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('1. displays header and new group button', (tester) async {
    mockDataSource.setGroups(testGroups);
    await pumpHomeScreen(tester);

    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('Manage your expenses with friends'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '+ New Group'), findsOneWidget);
  });

  testWidgets('2. shows list of groups', (tester) async {
    mockDataSource.setGroups(testGroups);
    await pumpHomeScreen(tester);

    expect(find.text('Trip to Goa'), findsOneWidget);
    expect(find.text('Dinner Club'), findsOneWidget);
    expect(find.text('2 members'), findsNWidgets(2));
  });

  testWidgets('5. shows empty state when no groups', (tester) async {
    mockDataSource.setGroups([]);
    await pumpHomeScreen(tester);

    expect(find.byIcon(Icons.group_off), findsOneWidget);
    expect(find.text('No groups yet'), findsOneWidget);
  });

  testWidgets('6. tapping a group navigates to GroupDetailScreen', (tester) async {
    mockDataSource.setGroups(testGroups);
    await pumpHomeScreen(tester);

    await tester.tap(find.text('Trip to Goa'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupDetailScreen), findsOneWidget);
  });

  testWidgets('7. tapping "+ New Group" opens dialog', (tester) async {
    mockDataSource.setGroups(testGroups);
    await pumpHomeScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, '+ New Group'));
    await tester.pumpAndSettle();

    expect(find.text('Create Group'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('8. can add members in create group dialog', (tester) async {
    mockDataSource.setGroups(testGroups);
    await pumpHomeScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, '+ New Group'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'New Group');
    await tester.enterText(find.byType(TextField).last, 'Eve');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Eve'), findsOneWidget);
  });
  testWidgets('10. group cards show member count and balance', (tester) async {
    mockDataSource.setGroups(testGroups);
    await pumpHomeScreen(tester);

    expect(find.text('2 members'), findsNWidgets(2));
    expect(find.textContaining('Rs'), findsNWidgets(2));
  });
}