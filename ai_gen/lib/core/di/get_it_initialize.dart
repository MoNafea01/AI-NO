import 'package:ai_gen/core/network/server_manager/server_manager.dart';
import 'package:ai_gen/core/services/app_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

initializeGetIt() {
  final dio = Dio(BaseOptions(
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    followRedirects: true,
    maxRedirects: 5,
  ));

  GetIt.I.registerSingleton<Dio>(dio);
  GetIt.I.registerSingleton<ServerManager>(ServerManager());
  GetIt.I.registerSingleton<AppServices>(AppServices());
}
