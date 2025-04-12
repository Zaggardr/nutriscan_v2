import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> register(
    String email,
    String password, {
    String? name,
    String? city,
  }) async {
    print('Register attempt: email=$email');
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Registration successful: ${result.user?.email}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: code=${e.code}, message=${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error during registration: $e');
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    print('Login attempt: email=$email');
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Login successful: ${result.user?.email}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: code=${e.code}, message=${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error during login: $e');
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    print('Reset password attempt: email=$email');
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: code=${e.code}, message=${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error during reset: $e');
      throw e;
    }
  }

  Future<void> sendEmailVerification(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  
}
