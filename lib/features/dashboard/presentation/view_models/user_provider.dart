import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../domain/model/user.dart';
import '../../data/datasource/remote/user_remote_datasource.dart';

final userProvider = FutureProvider<User>((ref) async {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  final user = await dataSource.getCurrentUser();
  
  String? fixedUrl = user.profileImage;
  if (fixedUrl != null) {
    // For Android emulator, replace localhost with 10.0.2.2
    if (Platform.isAndroid && fixedUrl.contains('localhost')) {
      fixedUrl = fixedUrl.replaceFirst('localhost', '192.168.1.115');
    }else if (fixedUrl.startsWith('/')) {
    fixedUrl = 'http://192.168.1.115:5000$fixedUrl';
  }
  
    // Add cache buster
    fixedUrl = '$fixedUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    print("👤 Final profile image URL: $fixedUrl");
    return User(
      id: user.id,
      username: user.username,
      email: user.email,
      profileImage: fixedUrl,
    );
  }
  return user;
});