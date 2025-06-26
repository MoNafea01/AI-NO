class ChangePasswordState {
  final bool obscureOld;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool isLoading;

  const ChangePasswordState({
    this.obscureOld = true,
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.isLoading = false,
  });

  ChangePasswordState copyWith({
    bool? obscureOld,
    bool? obscureNew,
    bool? obscureConfirm,
    bool? isLoading,
  }) {
    return ChangePasswordState(
      obscureOld: obscureOld ?? this.obscureOld,
      obscureNew: obscureNew ?? this.obscureNew,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
