abstract class AuthBase {
  Future<String> signInWithEmailAndPassword(String email, String password);

  Future<String> signInGoogle();

  Future<String> signInApple();
}