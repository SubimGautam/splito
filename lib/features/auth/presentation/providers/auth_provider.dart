import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/remote/remote_auth_datasource.dart';
import '../../data/datasource/local/local_auth_datasource.dart';

// Export the ViewModel so that authViewModelProvider is available when this file is imported
export '../view_model/auth_view_model.dart';

// Provider for RemoteAuthDataSourceImpl
final remoteAuthDataSourceProvider = Provider<RemoteAuthDataSourceImpl>((ref) {
  return RemoteAuthDataSourceImpl();
});

// Provider for LocalAuthDataSourceImpl
final localAuthDataSourceProvider = Provider<LocalAuthDataSourceImpl>((ref) {
  return LocalAuthDataSourceImpl();
});