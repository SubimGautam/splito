import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/user.dart';
import '../../data/datasource/remote/user_remote_datasource.dart';

final userProvider = FutureProvider<User>((ref) async {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return dataSource.getCurrentUser();
});