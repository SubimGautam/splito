import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splito_project/features/dashboard/domain/model/group_detail.dart';
import 'package:splito_project/features/dashboard/presentation/pages/home_screen.dart';
import 'package:splito_project/features/dashboard/presentation/view_models/groups_view_model.dart';
import 'package:splito_project/features/dashboard/data/datasource/remote/group_remote_datasource.dart';
import 'package:splito_project/features/dashboard/domain/model/group.dart';

// Fake data source that returns empty list immediately
class FakeGroupRemoteDataSource implements GroupRemoteDataSource {
  @override
  Future<List<Group>> getGroups() async => [];
  @override
  Future<GroupDetail> getGroupWithBalances(String groupId) => throw UnimplementedError();
  @override
  Future<Group> createGroup(String name, List<String> members) => throw UnimplementedError();
  @override
  Future<void> deleteGroup(String groupId) => throw UnimplementedError();
  @override
  Future<Group> updateGroup(String groupId, Map<String, dynamic> updates) => throw UnimplementedError();
}

void main() {
  testWidgets('HomeScreen builds without crashing', (tester) async {
    // Create view model with fake data source
    final fakeDataSource = FakeGroupRemoteDataSource();
    final groupsViewModel = GroupsViewModel(fakeDataSource);
    // Set state to empty list so it's not loading forever
    groupsViewModel.state = const AsyncValue.data([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupsViewModelProvider.overrideWith((ref) => groupsViewModel),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Only pump once – the widget tree is built
    await tester.pump();

    // If we got here, the screen built without errors
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}