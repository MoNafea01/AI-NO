import 'package:ai_gen/core/network/server_manager/server_manager.dart';
import 'package:ai_gen/core/services/app_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

initializeGetIt() {
  GetIt.I.registerSingleton<Dio>(Dio());
  GetIt.I.registerSingleton<ServerManager>(ServerManager());
  GetIt.I.registerSingleton<AppServices>(AppServices());
}
