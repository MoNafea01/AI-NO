import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

/// Network module for dependency injection
class NetworkModule {
  static void init(GetIt getIt) {
    // Network clients
    getIt.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) =>
              status != null && status >= 200 && status <= 300,
        ),
      ),
    );
  }
}
