import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<UserCredential> signUp({required String email, required String password}) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('FireBase Auth Exception: ${e.message}');
    } catch (e) {
      throw Exception('Exception: ${e.toString()}');
    }
  }

  Future<UserCredential> signIn({required String email, required String password}) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('FireBase Auth Exception: ${e.message}');
    } catch (e) {
      throw Exception('Exception: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception('FireBase Auth Exception: ${e.message}');
    } catch (e) {
      throw Exception('Exception: ${e.toString()}');
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('FireBase Auth Exception: ${e.message}');
    } catch (e) {
      throw Exception('Exception: ${e.toString()}');
    }
  }
}
