// features/auth/cubit/auth_state.dart
part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Map<String, dynamic> response;
  AuthSuccess(this.response);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
