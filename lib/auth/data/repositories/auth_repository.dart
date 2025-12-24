import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('FireBase Auth Sign Up Exception: ${e.message}');
    } catch (e) {
      throw Exception('Exception Sign Up: ${e.toString()}');
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('FireBase Auth Sign In Exception: ${e.message}');
    } catch (e) {
      throw Exception('Exception Sign In: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception('FireBase Auth Sign Out Exception: ${e.message}');
    } catch (e) {
      throw Exception('Exception Sign Out: ${e.toString()}');
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('FireBase Auth Reset Password Exception: ${e.message}');
    } catch (e) {
      throw Exception('Exception Reset Password: ${e.toString()}');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId:
            "546151690552-1qsb7dv8od5j0art9mkssfvf89rti48d.apps.googleusercontent.com",
      );

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(
        'FireBase Auth Sign In With Google Exception: ${e.message}',
      );
    } catch (e) {
      throw Exception('Exception Sign In With Google: ${e.toString()}');
    }
  }
}
