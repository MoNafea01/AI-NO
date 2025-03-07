import 'package:flutter_bloc/flutter_bloc.dart';

class MouseModeCubit extends Cubit<MouseModeState> {
  MouseModeCubit()
      : super(MouseModeState(
          isDropdownVisible: false,
          selectedMode: "Mouse Pointer",
          iconPath: "assets/images/arrow_Selector_Tool.png",
        ));

  void toggleDropdown() {
    emit(state.copyWith(isDropdownVisible: !state.isDropdownVisible));
  }

  void changeMouseMode(String mode, String iconPath) {
    emit(state.copyWith(
      selectedMode: mode,
      iconPath: iconPath,
      isDropdownVisible: false,
    ));
  }
}

class MouseModeState {
  final bool isDropdownVisible;
  final String selectedMode;
  final String iconPath;

  MouseModeState({
    required this.isDropdownVisible,
    required this.selectedMode,
    required this.iconPath,
  });

  MouseModeState copyWith({
    bool? isDropdownVisible,
    String? selectedMode,
    String? iconPath,
  }) {
    return MouseModeState(
      isDropdownVisible: isDropdownVisible ?? this.isDropdownVisible,
      selectedMode: selectedMode ?? this.selectedMode,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}
