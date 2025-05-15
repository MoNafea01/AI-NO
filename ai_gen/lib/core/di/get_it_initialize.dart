import 'package:get_it/get_it.dart';

import 'network_module.dart';
import 'service_module.dart';

/// Initialize all dependencies using GetIt
Future<void> initializeGetIt() async {
  final getIt = GetIt.instance;

  // Initialize all modules
  NetworkModule.init(getIt);
  ServiceModule.init(getIt);
}

/// Reset all dependencies
Future<void> resetGetIt() async {
  await GetIt.instance.reset();
}
