import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';

class SplashProvider extends CustomProvider {
  final _pref = getIt.getAsync<SharedPreferences>();
  SplashProvider() {
    Future.delayed(const Duration(seconds: 4), () {
      _pref.then((value) async {
        if (value.getBool(onboardingKey) == null) {
          add(-1);
          return;
        }
        try {
          final token = value.getString(tokenKey);
          // logg(token);
          // currentRole = fromString(value.getString(userRoleKey) ?? '');

          final loggedInUser = value.getString(userKey);
          // logg(loggedInUser);
          accessToken = '$token';
          if (loggedInUser == null) {
            add(0);
            return;
          } else {
            await getCachedUser();
            add(1);
            return;
          }
        } catch (e) {
          Logger().d(e);
          add(0);
        }
      });
    });
  }
}
