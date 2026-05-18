// data/remote/services/profile_firebase_service.dart
// Mirrors your AuthApiService — Firebase is the "HTTP client" here.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';

@lazySingleton
class ProfileFirebaseService {
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