import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splito_project/features/dashboard/presentation/pages/group_detail_screen.dart';
import 'package:splito_project/features/dashboard/presentation/view_models/group_detail_view_model.dart';
import 'package:splito_project/features/dashboard/data/datasource/remote/group_remote_datasource.dart';
import 'package:splito_project/features/dashboard/domain/model/group_detail.dart';
import 'package:splito_project/features/dashboard/domain/model/group.dart';

// Same fake data source – we only need getGroupWithBalances to return something
class FakeGroupRemoteDataSource implements GroupRemoteDataSource {
  @override
  Future<GroupDetail> getGroupWithBalances(String groupId) async {
    // Return a minimal valid GroupDetail
    return GroupDetail(
      group: Group(
        id: 'test',
        name: 'Test',
        members: [],
        createdBy: 'user',
        createdAt: DateTime.now(),
      ),
      balances: [],
      expenses: [],
      settlements: [],
    );
  }
  @override
  Future<List<Group>> getGroups() => throw UnimplementedError();
  @override
  Future<Group> createGroup(String name, List<String> members) => throw UnimplementedError();
  @override
  Future<void> deleteGroup(String groupId) => throw UnimplementedError();
  @override
  Future<Group> updateGroup(String groupId, Map<String, dynamic> updates) => throw UnimplementedError();
}

void main() {
  testWidgets('GroupDetailScreen builds without crashing', (tester) async {
    final fakeDataSource = FakeGroupRemoteDataSource();
    final detailViewModel = GroupDetailViewModel(fakeDataSource);
    // Pre-load the detail so state is data, not loading
    await detailViewModel.loadGroupDetail('test');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupDetailViewModelProvider.overrideWith((ref) => detailViewModel),
        ],
        child: const MaterialApp(home: GroupDetailScreen(groupId: 'test')),
      ),
    );

    await tester.pump(); // just one frame

    expect(find.byType(GroupDetailScreen), findsOneWidget);
  });
}