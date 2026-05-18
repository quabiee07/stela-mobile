import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'core_module_container.config.dart';

GetIt getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies() async => getIt.init();
