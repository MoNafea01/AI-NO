// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';

// // Model class for project data
// class ProjectItem extends Equatable {
//   final String id;
//   final String name;
//   final String projectDescription;
//   final String modelName;
//   final String modelDescription;
//   final String type;
//   final String typeDescription;
//   final DateTime dateCreated;
//   final bool isSelected;

//   const ProjectItem({
//     required this.id,
//     required this.name,
//     required this.projectDescription,
//     required this.modelName,
//     required this.modelDescription,
//     required this.type,
//     required this.typeDescription,
//     required this.dateCreated,
//     this.isSelected = false,
//   });

//   ProjectItem copyWith({
//     String? id,
//     String? name,
//     String? projectDescription,
//     String? modelName,
//     String? modelDescription,
//     String? type,
//     String? typeDescription,
//     DateTime? dateCreated,
//     bool? isSelected,
//   }) {
//     return ProjectItem(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       projectDescription: projectDescription ?? this.projectDescription,
//       modelName: modelName ?? this.modelName,
//       modelDescription: modelDescription ?? this.modelDescription,
//       type: type ?? this.type,
//       typeDescription: typeDescription ?? this.typeDescription,
//       dateCreated: dateCreated ?? this.dateCreated,
//       isSelected: isSelected ?? this.isSelected,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         id,
//         name,
//         projectDescription,
//         modelName,
//         modelDescription,
//         type,
//         typeDescription,
//         dateCreated,
//         isSelected
//       ];
// }

// // States for the project list
// enum ProjectFilterType { all, recent, favorite }

// class ProjectState extends Equatable {
//   final List<ProjectItem> allProjects;
//   final List<ProjectItem> filteredProjects;
//   final String searchQuery;
//   final ProjectFilterType filterType;
//   final bool isLoading;
//   final String? errorMessage;
//   final int currentPage;
//   final int pageSize;
//   final bool selectMode;
//   final bool allSelected;

//   const ProjectState({
//     this.allProjects = const [],
//     this.filteredProjects = const [],
//     this.searchQuery = '',
//     this.filterType = ProjectFilterType.all,
//     this.isLoading = false,
//     this.errorMessage,
//     this.currentPage = 1,
//     this.pageSize = 10,
//     this.selectMode = false,
//     this.allSelected = false,
//   });

//   int get totalPages => (filteredProjects.isEmpty
//               ? allProjects.length
//               : filteredProjects.length) <=
//           0
//       ? 1
//       : ((filteredProjects.isEmpty
//                   ? allProjects.length
//                   : filteredProjects.length) /
//               pageSize)
//           .ceil();

//   List<ProjectItem> get currentPageItems {
//     final sourceList = filteredProjects.isEmpty && searchQuery.isEmpty
//         ? allProjects
//         : filteredProjects;

//     final startIndex = (currentPage - 1) * pageSize;
//     final endIndex = startIndex + pageSize > sourceList.length
//         ? sourceList.length
//         : startIndex + pageSize;

//     return startIndex >= sourceList.length
//         ? []
//         : sourceList.sublist(startIndex, endIndex);
//   }

//   ProjectState copyWith({
//     List<ProjectItem>? allProjects,
//     List<ProjectItem>? filteredProjects,
//     String? searchQuery,
//     ProjectFilterType? filterType,
//     bool? isLoading,
//     String? errorMessage,
//     int? currentPage,
//     int? pageSize,
//     bool? selectMode,
//     bool? allSelected,
//   }) {
//     return ProjectState(
//       allProjects: allProjects ?? this.allProjects,
//       filteredProjects: filteredProjects ?? this.filteredProjects,
//       searchQuery: searchQuery ?? this.searchQuery,
//       filterType: filterType ?? this.filterType,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage ?? this.errorMessage,
//       currentPage: currentPage ?? this.currentPage,
//       pageSize: pageSize ?? this.pageSize,
//       selectMode: selectMode ?? this.selectMode,
//       allSelected: allSelected ?? this.allSelected,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         allProjects,
//         filteredProjects,
//         searchQuery,
//         filterType,
//         isLoading,
//         errorMessage,
//         currentPage,
//         pageSize,
//         selectMode,
//         allSelected
//       ];
// }

// class ProjectCubit extends Cubit<ProjectState> {
//   ProjectCubit() : super(const ProjectState());

//   // Initialize with dummy projects
//   void initializeProjects() {
//     final projects = List.generate(
//         25,
//         (index) => ProjectItem(
//               id: 'project-$index',
//               name: '${_getOrdinal(index + 1)} Project name',
//               projectDescription: 'description',
//               modelName: 'Model name',
//               modelDescription: 'Model description',
//               type: _getProjectType(index),
//               typeDescription: 'Dataset description',
//               dateCreated: DateTime(2025, 1, 4),
//             ));

//     emit(state.copyWith(allProjects: projects));
//   }

//   // Helper for ordinal numbers
//   String _getOrdinal(int number) {
//     if (number == 1) return '1st';
//     if (number == 2) return '2nd';
//     if (number == 3) return '3rd';
//     return '${number}th';
//   }

//   // Get project type based on index
//   static String _getProjectType(int index) {
//     final types = [
//       'Content curating app',
//       'Design software',
//       'Data prediction',
//       'Productivity app',
//       'Web app integrations',
//       'Sales CRM',
//       'Automation and workflow',
//     ];
//     return types[index % types.length];
//   }

//   // Filter projects by search query
//   void searchProjects(String query) {
//     if (query.isEmpty) {
//       emit(state.copyWith(
//         searchQuery: '',
//         filteredProjects: [],
//         currentPage: 1,
//       ));
//       return;
//     }

//     final filtered = state.allProjects
//         .where((project) =>
//             project.name.toLowerCase().contains(query.toLowerCase()) ||
//             project.type.toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     emit(state.copyWith(
//       searchQuery: query,
//       filteredProjects: filtered,
//       currentPage: 1,
//     ));
//   }

//   // Apply project type filter
//   void applyFilter(ProjectFilterType filterType) {
//     List<ProjectItem> filtered;

//     switch (filterType) {
//       case ProjectFilterType.all:
//         filtered = [];
//         break;
//       case ProjectFilterType.recent:
//         filtered = List.from(state.allProjects)
//           ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
//         filtered = filtered.take(10).toList();
//         break;
//       case ProjectFilterType.favorite:
//         // This would require a "favorite" property in the project model
//         filtered = state.allProjects.where((p) => p.id.contains('2')).toList();
//         break;
//     }

//     emit(state.copyWith(
//       filterType: filterType,
//       filteredProjects: filtered,
//       currentPage: 1,
//     ));
//   }

//   // Pagination methods
//   void goToPage(int page) {
//     if (page < 1 || page > state.totalPages) return;
//     emit(state.copyWith(currentPage: page));
//   }

//   void nextPage() {
//     if (state.currentPage < state.totalPages) {
//       emit(state.copyWith(currentPage: state.currentPage + 1));
//     }
//   }

//   void previousPage() {
//     if (state.currentPage > 1) {
//       emit(state.copyWith(currentPage: state.currentPage - 1));
//     }
//   }

//   // Selection methods
//   void toggleSelectMode() {
//     emit(state.copyWith(
//       selectMode: !state.selectMode,
//       allSelected: false,
//     ));

//     // Reset all selection states when exiting select mode
//     if (!state.selectMode) {
//       final updatedProjects =
//           state.allProjects.map((p) => p.copyWith(isSelected: false)).toList();

//       emit(state.copyWith(allProjects: updatedProjects));
//     }
//   }

//   void toggleProjectSelection(String projectId) {
//     final updatedProjects = state.allProjects.map((project) {
//       if (project.id == projectId) {
//         return project.copyWith(isSelected: !project.isSelected);
//       }
//       return project;
//     }).toList();

//     // Check if all visible projects are selected
//     final currentPageProjects = updatedProjects
//         .where((p) => state.currentPageItems.any((item) => item.id == p.id))
//         .toList();

//     final allCurrentPageSelected =
//         currentPageProjects.every((p) => p.isSelected);

//     emit(state.copyWith(
//       allProjects: updatedProjects,
//       allSelected: allCurrentPageSelected,
//     ));
//   }

//   void toggleSelectAll() {
//     final isSelectingAll = !state.allSelected;

//     final updatedProjects = state.allProjects.map((project) {
//       if (state.currentPageItems.any((p) => p.id == project.id)) {
//         return project.copyWith(isSelected: isSelectingAll);
//       }
//       return project;
//     }).toList();

//     emit(state.copyWith(
//       allProjects: updatedProjects,
//       allSelected: isSelectingAll,
//     ));
//   }

//   // Project management methods
//   void deleteSelectedProjects() {
//     final remainingProjects =
//         state.allProjects.where((project) => !project.isSelected).toList();

//     emit(state.copyWith(
//       allProjects: remainingProjects,
//       selectMode: false,
//       allSelected: false,
//     ));

//     // Re-apply search if needed
//     if (state.searchQuery.isNotEmpty) {
//       searchProjects(state.searchQuery);
//     }
//   }

//   // Create a new project
//   void createProject(ProjectItem project) {
//     final updatedProjects = [
//       project,
//       ...state.allProjects,
//     ];

//     emit(state.copyWith(allProjects: updatedProjects));
//   }
// }
