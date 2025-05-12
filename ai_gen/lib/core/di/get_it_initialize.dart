import 'package:ai_gen/core/network/server_manager/server_manager.dart';
import 'package:ai_gen/core/services/app_services.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

initializeGetIt() {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    followRedirects: true,
    maxRedirects: 5,
  ));

  // Add logging interceptor
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    logPrint: (object) {
      print('DIO LOG: $object');
    },
  ));

  GetIt.I.registerSingleton<Dio>(dio);
  GetIt.I.registerSingleton<ServerManager>(ServerManager());
  GetIt.I.registerSingleton<AppServices>(AppServices());
}
