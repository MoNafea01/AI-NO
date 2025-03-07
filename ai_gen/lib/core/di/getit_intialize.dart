import 'package:ai_gen/core/network/server_calls.dart';
import 'package:ai_gen/core/network/server_manager/server_manager.dart';
import 'package:ai_gen/features/node_view/data/functions/node_server_calls.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

initializeGetIt() {
  GetIt.I.registerSingleton<Dio>(Dio());
  GetIt.I.registerSingleton<ServerManager>(ServerManager());
  GetIt.I.registerSingleton<NodeServerCalls>(NodeServerCalls());
  GetIt.I.registerSingleton<ServerCalls>(ServerCalls());
}
