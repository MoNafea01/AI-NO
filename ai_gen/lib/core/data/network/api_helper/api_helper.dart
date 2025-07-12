import 'package:ai_gen/core/data/cache/cache_data.dart';
import 'package:ai_gen/core/data/cache/cache_helper.dart';
import 'package:ai_gen/core/data/cache/cahch_keys.dart';
import 'package:ai_gen/core/data/network/api_helper/end_points.dart';
import 'package:ai_gen/core/utils/helper/my_logger.dart';
import 'package:dio/dio.dart';

import 'api_response.dart';


class ApiHelper {
  // Singleton
  static final ApiHelper _instance = ApiHelper._init();
  factory ApiHelper() {
    // initialize the dio instance and the interceptors
    _instance.initDio();
    return _instance;
  }

  ApiHelper._init();

  // Dio instance with its options configured
  Dio dio = Dio(
    BaseOptions(
      baseUrl: EndPoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  void initDio() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Just Print the details of the call for observation purposes
          // MyLogger.yellow("--- Headers : ${options.headers.toString()}");
          MyLogger.yellow("Request --- endpoint : ${options.path.toString()}");
          // then continue the call
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Print the response in case of success
          MyLogger.green("--- Response : ${response.data.toString()}");
          // Continue the process
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // Print the error Body in case of failure
          MyLogger.red("--- Error : ${error.response?.data.toString()}");

          // Check if the error is due to an expired token
          if (error.response?.data['message'].contains('expired')) {
            MyLogger.bgMagenta('Refreshing Token');
            // refresh token
            try {
              ApiResponse apiResponse = await _instance.postRequest(
                endPoint: EndPoints.refreshToken,
                sendRefreshToken: true,
                isProtected: true,
              );
              // Check if the refresh token request was successful
              if (apiResponse.status) {
                // must update token & Cache it
                CacheData.accessToken = apiResponse.data['access_token'];
                await CacheHelper.saveData(
                  key: CacheKeys.accessToken,
                  value: CacheData.accessToken,
                );

                // Retry original request
                final options = error.requestOptions;
                if (options.data is FormData) {
                  final oldFormData = options.data as FormData;
                  // If the data is FormData, we need to rebuild it
                  // because Dio will not allow to send the old formdata again

                  // Convert FormData to map so it can be rebuilt
                  final Map<String, dynamic> formMap = {};
                  for (var entry in oldFormData.fields) {
                    formMap[entry.key] = entry.value;
                  }

                  // Add files if any
                  for (var file in oldFormData.files) {
                    formMap[file.key] = file.value;
                  }

                  // Rebuild new FormData
                  options.data = FormData.fromMap(formMap);
                }
                // Add the new token to the headers
                options.headers['Authorization'] =
                    'Bearer ${CacheData.accessToken}';
                final response = await dio.fetch(options);
                // because we handled the error and solved it
                return handler.resolve(response);
              } else {
                // In case Refresh token itself has expired or failed
                // must logout
                CacheHelper.removeData(key: CacheKeys.accessToken);
                CacheHelper.removeData(key: CacheKeys.refreshToken);
                //NavHelper.pushReplaceAll(() => LoginView());
                return handler.next(error);
              }
            } catch (e) {
              // In case of any error during the refresh token process
              // must logout
              CacheHelper.removeData(key: CacheKeys.accessToken);
              CacheHelper.removeData(key: CacheKeys.refreshToken);
             // NavHelper.pushReplaceAll(() => LoginView());
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  // Post Request
  Future<ApiResponse> postRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = false,
    bool isProtected = false,
    bool sendRefreshToken = false,
  }) async {
    return ApiResponse.fromResponse(
      await dio.post(
        endPoint,
        data: isFormData ? FormData.fromMap(data ?? {}) : data,
        options: Options(
          headers: {
            if (isProtected)
              'Authorization':
                  'Bearer ${sendRefreshToken ? CacheHelper.getData(key: CacheKeys.refreshToken) : CacheData.accessToken}',
          },
        ),
      ),
    );
  }

  Future<ApiResponse> getRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = false,
    bool isProtected = true,
    Map<String, dynamic>? query,
  }) async {
    return ApiResponse.fromResponse(
      await dio.get(
        endPoint,
        data: isFormData ? FormData.fromMap(data ?? {}) : data,
        options: Options(
          headers: {
            if (isProtected) 'Authorization': 'Bearer ${CacheData.accessToken}',
          },
        ),
        queryParameters: query,
      ),
    );
  }

  Future<ApiResponse> putRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = false,
    bool isProtected = false,
  }) async {
    return ApiResponse.fromResponse(
      await dio.put(
        endPoint,
        data: isFormData ? FormData.fromMap(data ?? {}) : data,
        options: Options(
          headers: {
            if (isProtected) 'Authorization': 'Bearer ${CacheData.accessToken}',
          },
        ),
      ),
    );
  }

  Future<ApiResponse> deleteRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = false,
    bool isProtected = false,
  }) async {
    return ApiResponse.fromResponse(
      await dio.delete(
        endPoint,
        data: isFormData ? FormData.fromMap(data ?? {}) : data,
        options: Options(
          headers: {
            if (isProtected) 'Authorization': 'Bearer ${CacheData.accessToken}',
          },
        ),
      ),
    );
  }
}
