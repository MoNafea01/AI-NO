import 'package:ai_gen/core/network/server_manager/server_manager.dart';
import 'package:ai_gen/core/network/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/core/network/services/interfaces/project_services_interface.dart';
import 'package:ai_gen/core/network/services/implementation/node_services.dart';
import 'package:ai_gen/core/network/services/implementation/project_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

/// Service module for dependency injection
class ServiceModule {
  static void init(GetIt getIt) {
    // Core Services
    getIt.registerLazySingleton<ServerManager>(() => ServerManager());
    getIt.registerLazySingleton<IProjectServices>(
      () => ProjectServices(getIt<Dio>()),
    );
    getIt.registerLazySingleton<INodeServices>(
      () => NodeServices(getIt<Dio>()),
    );
  }
}
