// lib/features/dashboard/presentation/cubit/dashboard_cubit.dart
import 'package:ai_gen/features/HomeScreen/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit()
      : super(DashboardState(
          isExpanded: true,
          selectedIndex: 0,
          searchQuery: '',
          currentPage: 1,
          filteredProjects: [],
        ));

  void toggleSidebar() {
    emit(state.copyWith(isExpanded: !state.isExpanded));
  }

  void selectNavigationItem(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  void searchProjects(String query, List<ProjectItem> allProjects) {
    final filteredProjects = query.isEmpty
        ? allProjects
        : allProjects
            .where((project) =>
                project.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    emit(state.copyWith(
      searchQuery: query,
      filteredProjects: filteredProjects,
    ));
  }

  void goToPage(int page) {
    emit(state.copyWith(currentPage: page));
  }
}

class DashboardState {
  final bool isExpanded;
  final int selectedIndex;
  final String searchQuery;
  final int currentPage;
  final List<ProjectItem> filteredProjects;

  DashboardState({
    required this.isExpanded,
    required this.selectedIndex,
    required this.searchQuery,
    required this.currentPage,
    required this.filteredProjects,
  });

  DashboardState copyWith({
    bool? isExpanded,
    int? selectedIndex,
    String? searchQuery,
    int? currentPage,
    List<ProjectItem>? filteredProjects,
  }) {
    return DashboardState(
      isExpanded: isExpanded ?? this.isExpanded,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      filteredProjects: filteredProjects ?? this.filteredProjects,
    );
  }
}
