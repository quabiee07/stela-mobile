import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/features/auth/data/dto/user_model_dto.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/auth/domain/models/user_payload.dart';
// Google Sign-In Service Class

@lazySingleton
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static final _firestore = getIt.get<FirebaseFirestore>();

  static bool isInitialize = false;
  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(serverClientId: dotenv.env['SERVER_ID']);
    }
    isInitialize = true;
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final pref = await getIt.getAsync<SharedPreferences>();

      // Step 1: Sign in with Firebase Auth
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("Login failed");
      }

      // Step 2: Fetch user profile from Firestore
      final userDoc = _firestore.collection("users").doc(user.uid);

      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        throw Exception("User profile not found");
      }

      // Step 3: Cache user locally
      final userModel = UserModelDto.fromJson(docSnapshot.data()!);

      final userString = jsonEncode(userModel.toJson());

      await pref.setString(userKey, userString);

      logg("User signed in successfully");
      logg(userString);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Email/password sign in failed");
    } catch (e) {
      logg("Error: $e");
      rethrow;
    }
  }

  Future<UserModel> createAccount(UserPayload payload) async {
    try {
      final _pref = getIt.getAsync<SharedPreferences>();
      final pref = await _pref;
      // Step 1: Create Firebase Auth account
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: payload.email.trim(),
            password: payload.password.trim(),
          );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("User creation failed");
      }

      // Step 2: Save profile to Firestore
      final userModel = UserModelDto(
        id: user.uid,
        name: payload.name,
        email: payload.email,
        provider: "email",
        avatarUrl: user.photoURL ?? "",
        age: payload.age,
        favoriteGenres: payload.favoriteGenres,
        level: 1,
        title: "New Reader",
        stats: StatsDto(
          storiesRead: 0,
          readTimeHours: 0,
          totalBadges: 0,
          fantasyBooksCompleted: 0,
          audioBooksCompleted: 0,
          genresRead: [],
          chaptersAtSpeed: 0,
          oceanBooksCompleted: 0,
          scifiBooksCompleted: 0,
          sharesCompleted: 0,
          totalXp: 0,
          sessionsAfter8Pm: 0,
        ),
        badges: [],
        streakData: StreakDataDto(
          currentStreakDays: 0,
          freezesAvailable: 1,
          lastFreezeUsedDate: null,
          weeklyProgress: [],
        ),
        createdAt: DateTime.now(),
        lastReadDate: null,
      );
      final userJson = userModel.toJson();
      logg(userJson);
      final userString = jsonEncode(userModel);
      pref.setString(userKey, userString);
      await _firestore.collection("users").doc(user.uid).set(userJson);

      return userModel.toEntity();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      logg("Error: $e");
      throw Exception(e.toString());
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final pref = await getIt.getAsync<SharedPreferences>();

      await initSignIn();

      // Step 1: Authenticate with Google
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;

      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(['email', 'profile']);

      String? accessToken = authorization?.accessToken;

      if (accessToken == null) {
        final retryAuthorization = await authorizationClient
            .authorizationForScopes(['email', 'profile']);

        if (retryAuthorization?.accessToken == null) {
          throw FirebaseAuthException(
            code: "auth_error",
            message: "Unable to get access token",
          );
        }

        authorization = retryAuthorization;
        accessToken = authorization?.accessToken;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      if (accessToken != null) {
        await pref.setString(tokenKey, accessToken);
      }

      // Step 2: Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("Google sign in failed");
      }

      // Step 3: Check if user exists in Firestore
      final userDoc = _firestore.collection("users").doc(user.uid);

      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Step 4: Create new user model (same structure as createAccount)

        final userModel = UserModelDto(
          id: user.uid,
          name: user.displayName ?? "",
          email: user.email ?? "",
          provider: "google",
          avatarUrl: user.photoURL ?? "",
          age: "0",
          favoriteGenres: [],
          level: 1,
          title: "New Reader",
          stats: StatsDto(
            storiesRead: 0,
            readTimeHours: 0,
            totalBadges: 0,
            fantasyBooksCompleted: 0,
            audioBooksCompleted: 0,
            genresRead: [],
            chaptersAtSpeed: 0,
            oceanBooksCompleted: 0,
            scifiBooksCompleted: 0,
            sharesCompleted: 0,
            totalXp: 0,
            sessionsAfter8Pm: 0,
          ),
          badges: [],
          streakData: StreakDataDto(
            currentStreakDays: 0,
            freezesAvailable: 1,
            lastFreezeUsedDate: null,
            weeklyProgress: [],
          ),
          createdAt: DateTime.now(),
          lastReadDate: null,
        );

        final userString = jsonEncode(userModel.toJson());

        await pref.setString(userKey, userString);

        await userDoc.set(userModel.toJson());

        logg("User created");
        logg(userString);
      } else {
        // Existing user → load + cache

        final existingUser = UserModelDto.fromJson(docSnapshot.data()!);

        final userString = jsonEncode(existingUser.toJson());

        await pref.setString(userKey, userString);

        logg("User already exists");
        logg(userString);
      }

      return userCredential;
    } catch (e) {
      logg("Error: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      logg('Error signing out: $e');
      rethrow;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
