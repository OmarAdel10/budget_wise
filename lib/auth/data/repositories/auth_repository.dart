import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isEmailPasswordProvider => _firebaseAuth.currentUser?.providerData.any((provider) => provider.providerId == 'password') ?? false;


  Future<bool> isUserUsingGoogleProvider() async {
    try {
      return _firebaseAuth.currentUser?.providerData.any(
            (provider) => provider.providerId == 'google.com',
          ) ??
          false;
    } catch (e) {
      throw Exception(
        'Exception Is User Using Google Provider: ${e.toString()}',
      );
    }
  }


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

  Future<bool> localAuth() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;

      if (canAuthenticateWithBiometrics) {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to access the app',
          biometricOnly: false,
          persistAcrossBackgrounding: true,
        );

        return didAuthenticate;
      } else {
        throw Exception('Biometrics not available');
      }
    } catch (e) {
      throw Exception('Exception Local Auth: ${e.toString()}');
    }
  }

  Future<void> updateProfileUserName({required String name}) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(name);
      await _firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(
        'FireBase Auth Update Profile User Name Exception: ${e.message}',
      );
    } catch (e) {
      throw Exception('Exception Update Profile User Name: ${e.toString()}');
    }
  }

  Future<void> updateProfileUserPassword({required String password}) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(password);
      await _firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(
        'FireBase Auth Update Profile User Password Exception: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Exception Update Profile User Password: ${e.toString()}',
      );
    }
  }

  // Future<void> updateProfileUserEmail({required String newEmail}) async {
  //   try {
  //     if (isEmailPasswordProvider) {
  //       final credential = EmailAuthProvider.credential(
  //         email: _firebaseAuth.currentUser!.email!,
  //         password: currentUser?.,
  //       );
  //       await currentUser?.reauthenticateWithCredential(credential);
  //       await currentUser?.updateEmail(newEmail);
  //       await currentUser?.reload();
  //     } else {
  //       throw Exception('User is not using email password provider');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     throw Exception(
  //       'FireBase Auth Update Profile User Email Exception: ${e.message}',
  //     );
  //   } catch (e) {
  //     throw Exception('Exception Update Profile User Email: ${e.toString()}');
  //   }
  // }

  // Future<void> updateProfileUserPhoto({required String photoUrl}) async {
  //   try {
  //     await _firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
  //   } on FirebaseAuthException catch (e) {
  //     throw Exception(
  //       'FireBase Auth Update Profile User Photo Exception: ${e.message}',
  //     );
  //   } catch (e) {
  //     throw Exception('Exception Update Profile User Photo: ${e.toString()}');
  //   }
  // }

  
}
