import 'package:ai_gen/core/classes/json_class.dart';
import 'package:ai_gen/core/classes/model_class.dart';
import 'package:dio/dio.dart';

class ApiCall {
  Future<Map<String, dynamic>> makeAPICall(
    String endpoint, {
    required Map<String, dynamic>? apiData,
    Map<String, dynamic> Function(Map<String, dynamic>)? processResponse,
  }) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        "http://127.0.0.1:8000/api/$endpoint",
        data: apiData,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.data);
        final jsonResponse = Map<String, dynamic>.from(response.data);

        // Process response if a processor function is provided
        if (processResponse != null) {
          return processResponse(jsonResponse);
        }

        return jsonResponse;
      } else {
        throw Exception('Failed to perform the operation');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Failed to perform the operation with status code ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> trainTestSplit(
    List<dynamic> data, {
    double testSize = 0.2,
    int? randomState,
  }) async {
    return await makeAPICall(
      'train_test_split',
      apiData: {
        'data': data,
        'test_size': testSize,
        'random_state': randomState,
      },
      processResponse: (response) => {
        'X_train': List<dynamic>.from(response['train_data']),
        'X_test': List<dynamic>.from(response['test_data']),
      },
    );
  }

  Future<Map<String, dynamic>> fitModel(
    AIModel model,
    Nafe3Json? x,
    Nafe3Json? y,
  ) async {
    return await makeAPICall(
      'fit_model',
      apiData: {
        "X": {
          "message": "Data split successful",
          "data": [
            [1, 2, 3, 4, 5],
            [1, 2, 3, 4, 5]
          ],
          "params": {"test_size": 0.25, "random_state": 42},
          "node_name": "TrainTestSplit",
          "node_type": "preprocessing",
          "node_id": 1844241157680
        },
        "y": {
          "data": [
            [0, 1]
          ]
        },
        'model': model.toJson(),
      },
      processResponse: (response) => response,
    );
  }

  Future<Map<String, dynamic>> predict(
    AIModel model,
    Nafe3Json? x,
  ) async {
    return await makeAPICall(
      'predict',
      apiData: {
        'X': {
          "message": "Data split successful",
          "data": [
            [6, 7, 8, 9, 10]
          ],
          "params": {"test_size": 0.25, "random_state": 42},
          "node_name": "TrainTestSplit",
          "node_type": "preprocessing",
          "node_id": 2308519656384
        },
        'model': model.toJson(),
      },
      processResponse: (response) => response,
    );
  }

  Future<Map<String, dynamic>> fit_preprocessor(
    Nafe3Json? data,
    Nafe3Json? preprocessor,
  ) async {
    return await makeAPICall(
      'fit_preprocessor',
      apiData: {
        'data': data,
        'preprocessor': preprocessor,
      },
      processResponse: (response) => response,
    );
  }

  Future<Map<String, dynamic>> transform(
    Nafe3Json? data,
    Nafe3Json? preprocessor,
  ) async {
    return await makeAPICall(
      'transform',
      apiData: {
        'data': data,
        'preprocessor': preprocessor,
      },
      processResponse: (response) => response,
    );
  }
}
