import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/services/app_services.dart';
import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final AppServices _appServices = GetIt.I.get<AppServices>();

  loadHomePage() async {
    try {
      emit(HomeLoading());

      final List<ProjectModel> projects = await _appServices.getAllProjects();

      emit(HomeSuccess(projects: projects));
    } catch (e) {
      print(e);
      emit(HomeFailure(errMsg: e.toString()));
    }
  }
}
