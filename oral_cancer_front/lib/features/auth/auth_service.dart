import 'dart:convert';
import '../../core/api_client.dart';
import '../../core/auth_storage.dart';

class AuthService {
  static Future<bool> login(String phone, String password) async {
    final res = await ApiClient.post('/auth/login', {
      'phone': phone,
      'password': password,
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await AuthStorage.save(data['token'], data['role'], data['name']);
      return true;
    }
    return false;
  }
}
