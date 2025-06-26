import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<int> {
  SettingsCubit() : super(0); // Default tab is 0

  void setCurrentTab(int tabIndex) => emit(tabIndex);
}
