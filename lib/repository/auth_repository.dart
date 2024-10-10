import 'package:flutter_writer_project/base/auth_base.dart';
import 'package:flutter_writer_project/service/api/api_auth_service.dart';
import 'package:flutter_writer_project/service/base/auth_service.dart';
import 'package:flutter_writer_project/tools/locator.dart';

class AuthRepository implements AuthBase {
  AuthService _service = locator<ApiAuthService>();

  @override
  Future<String> signInGoogle() async {
    return await _service.signInGoogle();
  }

  @override
  Future<String> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _service.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<String> signInApple() async{
    return await _service.signInApple();
  }
}
