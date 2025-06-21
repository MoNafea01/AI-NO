import 'package:ai_gen/features/HomeScreen/home_screen.dart';

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
