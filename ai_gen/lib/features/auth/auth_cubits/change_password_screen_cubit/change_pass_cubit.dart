import 'package:ai_gen/features/auth/auth_cubits/change_password_screen_cubit/change_pass_event.dart';
import 'package:ai_gen/features/auth/auth_cubits/change_password_screen_cubit/change_pass_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc() : super(const ChangePasswordState()) {
    on<ToggleOldPasswordVisibility>((event, emit) {
      emit(state.copyWith(obscureOld: !state.obscureOld));
    });

    on<ToggleNewPasswordVisibility>((event, emit) {
      emit(state.copyWith(obscureNew: !state.obscureNew));
    });

    on<ToggleConfirmPasswordVisibility>((event, emit) {
      emit(state.copyWith(obscureConfirm: !state.obscureConfirm));
    });

    on<SubmitPasswordChange>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      await Future.delayed(
          const Duration(milliseconds: 500)); // simulate loading
      emit(state.copyWith(isLoading: false));
    });
  }
}
