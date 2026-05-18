import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/domain/utils/utilities.dart';
import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_state.dart';
import 'package:stela_mobile/features/profile/domain/models/user_profile.dart';

class HomeProvider extends CustomProvider {
  final state = HomeState();

  void setIndex(int index) {
    state.selectedIndex = index;
    notifyListeners();
  }

  Future<void> getFirestoreUser() async {
    try {
      onLoad();
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(cachedUser?.id);
      final userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        final user = UserProfile.fromJson(userData!);
        state.firstName = user.name;
        state.profilePicture = user.avatarUrl;
        notifyListeners();
      }
    } on FirebaseException catch (e) {
      add(e.toString());
      logg(e.toString());
    } catch (e) {
      add(e.toString());
      logg(e.toString());
    }
  }

  void setFirstName(String name) {
    state.firstName = name;
    logg(state.firstName);
    notifyListeners();
  }

  void setProfilePicture(String url) {
    state.profilePicture = url;
    logg(state.profilePicture);
    notifyListeners();
  }
}
