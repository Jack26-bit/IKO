import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _userIdKey = 'user_id';

  static Future<void> saveUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  static Future<int?> getUserId() async {
    final value = await _storage.read(key: _userIdKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _userIdKey);
  }
}
