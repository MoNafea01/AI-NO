// import 'package:ai_gen/core/models/project_model.dart';
// import 'package:ai_gen/core/data/network/services/interfaces/project_services_interface.dart';
// import 'package:bloc/bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:meta/meta.dart';

// part 'home_state.dart';

// class HomeCubit extends Cubit<HomeState> {
//   HomeCubit() : super(HomeInitial());

//    final IProjectServices _appServices = GetIt.I.get<IProjectServices>();
//    static HomeCubit get(context) => BlocProvider.of(context);

//   // Store all projects and filtered projects
//   List<ProjectModel> _allProjects = [];
//   List<ProjectModel> _filteredProjects = [];
//   String _currentSearchQuery = '';

//  // final IProjectServices _appServices = GetIt.I.get<IProjectServices>();

//   // loadHomePage() async {
//   //   try {
//   //     emit(HomeLoading());

//   //     final List<ProjectModel> projects = await _appServices.getAllProjects();

//   //     emit(HomeSuccess(projects: projects));
//   //   } catch (e) {
//   //     print(e);
//   //     emit(HomeFailure(errMsg: e.toString()));
//   //   }
//   // }
//   loadHomePage() async {
//     try {
//       emit(HomeLoading());

//       final List<ProjectModel> projects = await _appServices.getAllProjects();

//       // Store all projects
//       _allProjects = projects;
//       _filteredProjects = List.from(_allProjects);

//       emit(HomeSuccess(projects: _filteredProjects));
//     } catch (e) {
//       print(e);
//       emit(HomeFailure(errMsg: e.toString()));
//     }
//   }
//    // New method for search functionality
//   void searchProjects(String query) {
//     _currentSearchQuery = query.toLowerCase().trim();

//     if (_currentSearchQuery.isEmpty) {
//       // Show all projects when search is empty
//       _filteredProjects = List.from(_allProjects);
//     } else {
//       // Filter projects based on search query
//       _filteredProjects = _allProjects.where((project) {
//         final projectName = (project.name ?? '').toLowerCase();
//         final projectDescription = (project.description ?? '').toLowerCase();

//         return projectName.contains(_currentSearchQuery) ||
//             projectDescription.contains(_currentSearchQuery);
//       }).toList();
//     }

//     // Emit new state with filtered projects
//     if (_filteredProjects.isEmpty && _currentSearchQuery.isNotEmpty) {
//       emit(HomeSearchEmpty(query: _currentSearchQuery));
//     } else {
//       emit(HomeSuccess(projects: _filteredProjects));
//     }
//   }

  

//   // Getters for accessing current state
//   List<ProjectModel> get filteredProjects => _filteredProjects;
//   String get currentSearchQuery => _currentSearchQuery;
//   List<ProjectModel> get allProjects => _allProjects;
// }
