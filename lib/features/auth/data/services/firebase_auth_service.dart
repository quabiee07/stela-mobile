import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/data/storage/secure_token_storage.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';

@lazySingleton
class FirebaseAuthService {
  FirebaseAuthService(this._tokenStorage);

  final SecureTokenStorage _tokenStorage;

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool isInitialize = false;

  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(serverClientId: dotenv.env['SERVER_ID']);
    }
    isInitialize = true;
  }

  Future<void> _persistFirebaseIdToken(User user) async {
    final token = await user.getIdToken();
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("Login failed");
      }

      await _persistFirebaseIdToken(user);
      logg("User signed in successfully");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Email/password sign in failed");
    } catch (e) {
      logg("Error: $e");
      rethrow;
    }
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed");
      }

      await _persistFirebaseIdToken(user);
      logg("User account created successfully");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      logg("Error: $e");
      throw Exception(e.toString());
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      logg("Password reset email sent successfully");
      return true;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      logg("Error: $e");
      throw Exception(e.toString());
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await initSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;

      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(['email', 'profile']);

      String? googleAccessToken = authorization?.accessToken;

      if (googleAccessToken == null) {
        final retryAuthorization = await authorizationClient
            .authorizationForScopes(['email', 'profile']);

        if (retryAuthorization?.accessToken == null) {
          throw FirebaseAuthException(
            code: "auth_error",
            message: "Unable to get access token",
          );
        }

        authorization = retryAuthorization;
        googleAccessToken = authorization?.accessToken;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAccessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("Google sign in failed");
      }

      // Persist Firebase ID token (never the Google OAuth access token).
      await _persistFirebaseIdToken(user);
      logg("Google sign in successful");
      return userCredential;
    } catch (e) {
      logg("Error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _tokenStorage.clearToken();
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      logg('Error signing out: $e');
      rethrow;
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
