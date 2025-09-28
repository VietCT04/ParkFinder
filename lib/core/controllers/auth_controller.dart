import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<User?> signIn(String email, String password) async {
    return await _authService.signInWithFirestore(email, password);
  }

  Future<User?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    // You can perform UI validations here or in the UI
    if (password != confirmPassword) {
      // Return null or throw an exception
      return null;
    }

    // Call the AuthService
    final user = await _authService.registerUser(
      email: email,
      password: password,
      name: name,
      phoneNumber: phone,
    );
    return user;
  }

  Future<void> signOut() async {
    return await _authService.signOut();
  }
}
