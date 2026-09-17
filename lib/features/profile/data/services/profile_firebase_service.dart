// data/remote/services/profile_firebase_service.dart
// Mirrors your AuthApiService — Firebase is the "HTTP client" here.
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';

@lazySingleton
class ProfileFirebaseService {
  ProfileFirebaseService(this._storage);

  final FirebaseStorage _storage;
  final _firestore = getIt.get<FirebaseFirestore>();

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('User $userId not found');
    }
    return {'id': doc.id, ...doc.data()!};
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _users.doc(userId).set(data, SetOptions(merge: true));
  }

  /// Uploads a profile photo and returns a download URL for [avatarUrl].
  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    final safeExt = (ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'webp')
        ? ext
        : 'jpg';
    final ref = _storage.ref().child('avatars/$userId/profile.$safeExt');
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$safeExt'),
    );
    return ref.getDownloadURL();
  }

  // Granular stat update — avoids a full document overwrite on every session.
  Future<void> patchStats(String userId, Map<String, dynamic> fields) async {
    await _users.doc(userId).update(fields);
  }

  Stream<Map<String, dynamic>> watchProfile(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('User $userId not found');
      }
      return {'id': doc.id, ...doc.data()!};
    });
  }
}
