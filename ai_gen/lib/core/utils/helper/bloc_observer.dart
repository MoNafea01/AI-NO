import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver implements BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    log('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  void onClose(BlocBase bloc) {
    log('onClose -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onCreate(BlocBase bloc) {
    log('onCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('onError -- bloc: ${bloc.runtimeType}, error: $error, stackTrace: $stackTrace');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    log('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    log('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }
}
