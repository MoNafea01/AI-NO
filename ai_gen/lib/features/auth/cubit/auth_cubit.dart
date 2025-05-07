// features/auth/cubit/auth_cubit.dart
import 'package:ai_gen/features/auth/data/services/auth_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final result =
          await _authService.login(UserModel(email: email, password: password));
      emit(AuthSuccess(result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await _authService
          .register(UserModel(email: email, password: password));
      emit(AuthSuccess(result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
