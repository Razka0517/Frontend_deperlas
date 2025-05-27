import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<User?> login(String username, String password) async {
    final response = await _api.login(username, password);

    // COCOKKAN DENGAN RESPONSE JSON (pakai 'user' bukan 'data')
    if (response['success'] == true && response['user'] != null) {
      final data = response['user'];

      return User(
        username: data['nama'],
        role: data['role'].toLowerCase(),
        userId: data['user_id'],
      );
    }
    return null;
  }
}
