import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/node_view/data/api_services/node_server_calls.dart';
import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final NodeServerCalls _nodeServerCalls = GetIt.I.get<NodeServerCalls>();

  loadHomePage() async {
    try {
      emit(HomeLoading());

      final List<ProjectModel> projects =
          await _nodeServerCalls.getAllProjects();

      emit(HomeSuccess(projects: projects));
    } catch (e) {
      emit(HomeFailure(errMsg: e.toString()));
    }
  }
}
