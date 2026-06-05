import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../core/api_service.dart';

class UserNotifier extends AsyncNotifier<User> {
  @override
  FutureOr<User> build() async {
    return _fetchUser();
  }

  Future<User> _fetchUser() async {
    final response = await apiService.client.get('/users/me');
    return User.fromJson(response.data);
  }

  Future<void> refreshUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchUser());
  }

  Future<void> updateAvatar(String avatarUrl) async {
    try {
      final response = await apiService.client.patch('/users/me/avatar', data: {'avatar_url': avatarUrl});
      state = AsyncData(User.fromJson(response.data));
    } catch (e) {
      rethrow;
    }
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User>(() {
  return UserNotifier();
});
