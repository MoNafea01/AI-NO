abstract class ChangePasswordEvent {}

class ToggleOldPasswordVisibility extends ChangePasswordEvent {}

class ToggleNewPasswordVisibility extends ChangePasswordEvent {}

class ToggleConfirmPasswordVisibility extends ChangePasswordEvent {}

class SubmitPasswordChange extends ChangePasswordEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  SubmitPasswordChange(
      this.oldPassword, this.newPassword, this.confirmPassword);
}
