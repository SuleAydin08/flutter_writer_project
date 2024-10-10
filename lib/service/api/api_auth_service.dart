
import 'package:flutter_writer_project/service/base/auth_service.dart';

class ApiAuthService implements AuthService {
  @override
  Future<String> signInGoogle() async {
    return "";
  }

  @override
  Future<String> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return "";
  }

  @override
  Future<String> signInApple() async {
    return "";
  }
}
