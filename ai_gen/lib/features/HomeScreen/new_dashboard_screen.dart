// ignore_for_file: deprecated_member_use

import 'package:ai_gen/features/HomeScreen/cubit/dashboard_cubit/dash_board_cubit.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit/user_profile_cubit.dart';

import 'package:ai_gen/features/HomeScreen/project_screen.dart';
import 'package:ai_gen/features/HomeScreen/widgets/build_side_bar_dashboard.dart';

import 'package:ai_gen/features/architecturesScreen/architecture_screen.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:ai_gen/features/screens/HomeScreen/home_screen.dart';
import 'package:ai_gen/features/screens/HomeScreen/widgets/project_table.dart';

import 'package:ai_gen/features/settings_screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ai_gen/features/HomeScreen/profile_screen.dart';

import '../datasetScreen/dataset_screen.dart';
import '../docsScreen/docs_screen.dart';
import '../learnScreen/learn_screen.dart';
import '../modelScreen/model_screen.dart';
import 'data/enum_app_screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashboardCubit(),
        ),
        BlocProvider(
          create: (context) => HomeCubit()..loadHomePage(),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(
            context.read<AuthProvider>(),
          )..loadProfile(
          ),
        ),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  // Helper method to get the widget based on the selected screen
  Widget _getScreenWidget(AppScreen screen) {
    switch (screen) {
      case AppScreen.explore:
        return const HomeScreen();
      //return ProjectsScreen();
      //ProjectsTable
      case AppScreen.architectures:
        return const ArchitecturesScreen();
      case AppScreen.models:
        return const ModelsScreen();
      case AppScreen.datasets:
        return const DatasetsScreen();
      case AppScreen.learn:
        return const LearnScreen();
      case AppScreen.docs:
        return const DocsScreen();
      case AppScreen.settings:
        return const SettingsScreen();
      case AppScreen.profile:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return Row(
            children: [
              // Left Sidebar
              buildSidebar(context, state),

              // Main Content
              Expanded(
                child: _getScreenWidget(state
                    .selectedScreen), // Dynamically display the selected screen
              ),
            ],
          );
        },
      ),
    );
  }
}

// class DashboardCubit extends Cubit<DashboardState> {
//   DashboardCubit()
//       : super(DashboardState(
//           isExpanded: true,
//           selectedScreen: AppScreen.explore, // Start with ExploreScreen
//           searchQuery: '',
//           currentPage: 1,
//           filteredProjects: [],
//         ));

//   void toggleSidebar() {
//     emit(state.copyWith(isExpanded: !state.isExpanded));
//   }

//   void selectNavigationItem(AppScreen screen) {
//     // Changed to AppScreen
//     emit(state.copyWith(selectedScreen: screen));
//   }

//   void searchProjects(String query, List<ProjectItem> allProjects) {
//     final filteredProjects = query.isEmpty
//         ? allProjects
//         : allProjects
//             .where((project) =>
//                 project.name.toLowerCase().contains(query.toLowerCase()))
//             .toList();

//     emit(state.copyWith(
//       searchQuery: query,
//       filteredProjects: filteredProjects,
//     ));
//   }

//   void goToPage(int page) {
//     emit(state.copyWith(currentPage: page));
//   }
// }

// class DashboardState {
//   final bool isExpanded;
//   final AppScreen selectedScreen; // Changed to AppScreen
//   final String searchQuery;
//   final int currentPage;
//   final List<ProjectItem> filteredProjects;

//   DashboardState({
//     required this.isExpanded,
//     required this.selectedScreen, // Changed to AppScreen
//     required this.searchQuery,
//     required this.currentPage,
//     required this.filteredProjects,
//   });

//   DashboardState copyWith({
//     bool? isExpanded,
//     AppScreen? selectedScreen, // Changed to AppScreen
//     String? searchQuery,
//     int? currentPage,
//     List<ProjectItem>? filteredProjects,
//   }) {
//     return DashboardState(
//       isExpanded: isExpanded ?? this.isExpanded,
//       selectedScreen:
//           selectedScreen ?? this.selectedScreen, // Changed to AppScreen
//       searchQuery: searchQuery ?? this.searchQuery,
//       currentPage: currentPage ?? this.currentPage,
//       filteredProjects: filteredProjects ?? this.filteredProjects,
//     );
//   }
// }

// // --- Main Dashboard Screen ---
// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => DashboardCubit(),
//       child: const _DashboardView(),
//     );
//   }
// }

// class _DashboardView extends StatelessWidget {
//   const _DashboardView();

//   // Helper method to get the widget based on the selected screen
//   Widget _getScreenWidget(AppScreen screen) {
//     switch (screen) {
//       case AppScreen.explore:
//         return ProjectsScreen();
//       case AppScreen.architectures:
//         return const ArchitecturesScreen();
//       case AppScreen.models:
//         return const ModelsScreen();
//       case AppScreen.datasets:
//         return const DatasetsScreen();
//       // case AppScreen.projects:
//       //   return ProjectsScreen();
//       // Your existing ProjectsScreen
//       case AppScreen.learn:
//         return const LearnScreen();
//       case AppScreen.docs:
//         return const DocsScreen();
//       case AppScreen.settings:
//         return const SettingsScreen();
//       case AppScreen.profile:
//         return const ProfileScreen();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<DashboardCubit, DashboardState>(
//         builder: (context, state) {
//           return Row(
//             children: [
//               // Left Sidebar
//               _buildSidebar(context, state),

//               // Main Content
//               Expanded(
//                 child: _getScreenWidget(state
//                     .selectedScreen), // Dynamically display the selected screen
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSidebar(BuildContext context, DashboardState state) {
//     return Container(
//       width: state.isExpanded ? 230 : 110,
//       color: Colors.white,
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 SvgPicture.asset(
//                   AssetsPaths.projectLogoIcon,
//                   width: 24,
//                   height: 24,
//                   color: Colors.blue,
//                 ),
//                 if (state.isExpanded) const SizedBox(width: 8),
//                 if (state.isExpanded)
//                   const Text(
//                     'Model Craft',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(
//                     state.isExpanded ? Icons.chevron_left : Icons.chevron_right,
//                     size: 20,
//                   ),
//                   onPressed: () {
//                     context.read<DashboardCubit>().toggleSidebar();
//                   },
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   _sidebarItem(
//                     context,
//                     AssetsPaths.exploreIcon,
//                     'Explore',
//                     AppScreen.explore, // Use enum
//                     state.isExpanded,
//                   ),
//                   _sidebarItem(
//                     context,
//                     AssetsPaths.architectureIcon,
//                     'Architectures',
//                     AppScreen.architectures, // Use enum
//                     state.isExpanded,
//                   ),
//                   _sidebarItem(
//                     context,
//                     AssetsPaths.modelIcon,
//                     'Models',
//                     AppScreen.models, // Use enum
//                     state.isExpanded,
//                   ),
//                   _sidebarItem(
//                     context,
//                     AssetsPaths.dataSetsIcon,
//                     'Datasets',
//                     AppScreen.datasets, // Use enum
//                     state.isExpanded,
//                   ),
//                   _sidebarItem(
//                     context,
//                     AssetsPaths.learnIcon,
//                     'Learn',
//                     AppScreen.learn, // Use enum
//                     state.isExpanded,
//                   ),
//                   _sidebarItem(
//                     context,
//                     AssetsPaths.docsIcon,
//                     'Docs',
//                     AppScreen.docs, // Use enum for Docs
//                     state.isExpanded,
//                   ),
//                   _sidebarItem(
//                     context,
//                     AssetsPaths.settingIcon,
//                     'Settings',
//                     AppScreen.settings, // Use enum
//                     state.isExpanded,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const Divider(),
//           _ProfileWidget(
//             isExpanded: state.isExpanded,
//             onTap: () {
//               context
//                   .read<DashboardCubit>()
//                   .selectNavigationItem(AppScreen.profile);
//               context
//                   .read<ProfileCubit>()
//                   .loadProfile(); // Keep your cubit logic
//             },
//           ),
//           const SizedBox(height: 8),
//           logoutButton(context, state.isExpanded),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _sidebarItem(
//     BuildContext context,
//     String iconPath,
//     String label,
//     AppScreen screenType, // Now takes AppScreen
//     bool isExpanded,
//   ) {
//     final bool isActive =
//         context.watch<DashboardCubit>().state.selectedScreen ==
//             screenType; // Compare with AppScreen
//     return InkWell(
//       onTap: () {
//         context
//             .read<DashboardCubit>()
//             .selectNavigationItem(screenType); // Select the screen type
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         decoration: BoxDecoration(
//           color: isActive ? Colors.blue : Colors.transparent,
//           borderRadius: isActive
//               ? const BorderRadius.only(
//                   topRight: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 )
//               : null,
//         ),
//         child: Row(
//           children: [
//             SvgPicture.asset(
//               iconPath,
//               width: 20,
//               height: 20,
//               color: isActive ? Colors.white : Colors.grey.shade700,
//             ),
//             if (isExpanded) const SizedBox(width: 12),
//             if (isExpanded)
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
//                   color: isActive ? Colors.white : Colors.grey.shade800,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- Modified ProfileWidget to handle screen selection ---
// class _ProfileWidget extends StatelessWidget {
//   final bool isExpanded;
//   final VoidCallback onTap; // Callback to handle profile screen selection

//   const _ProfileWidget({required this.isExpanded, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     // Note: Assuming AuthProvider is correctly set up higher in your widget tree
//     final userProfile = context.watch<AuthProvider>().userProfile;
//     final userName = userProfile?.username;
//     final email = userProfile?.email;

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 8.0),
//           child: InkWell(
//             onTap: onTap, // Use the provided onTap callback
//             child: isExpanded
//                 ? const Text("Profile", style: TextStyle(color: Colors.black87))
//                 : const Icon(Icons.person, color: Colors.black87),
//           ),
//         ),
//         if (isExpanded) // Only show details if expanded
//           Row(
//             children: [
//               const CircleAvatar(
//                 backgroundColor: Colors.blue,
//                 radius: 16,
//                 child: Text('',
//                     style: TextStyle(fontSize: 12, color: Colors.white)),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       userName ?? 'username',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 14,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       email ?? 'example@gmail.com',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade700,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//       ],
//     );
//   }
// }

// // --- Your existing ProjectsScreen and supporting classes ---
// // This part remains mostly as you provided it, as it's the content
// // for one of your dynamic screens.
// class ProjectsScreen extends StatelessWidget {
//   ProjectsScreen({super.key});

//   final List<ProjectItem> projects = [
//     ProjectItem(
//       name: '1st Project name',
//       projectDescription: 'description',
//       modelName: 'Model name',
//       modelDescription: 'Model description',
//       type: 'Content curating app',
//       typeDescription: 'Dataset description',
//       dateCreated: DateTime(2025, 1, 4),
//     ),
//     ProjectItem(
//       name: '2nd Project name',
//       projectDescription: 'description',
//       modelName: 'Model name',
//       modelDescription: 'Model description',
//       type: 'Design software',
//       typeDescription: 'Dataset description',
//       dateCreated: DateTime(2025, 1, 4),
//     ),
//     ProjectItem(
//       name: '3rd Project name',
//       projectDescription: 'description',
//       modelName: 'Model name',
//       modelDescription: 'Model description',
//       type: 'Data prediction',
//       typeDescription: 'Dataset description',
//       dateCreated: DateTime(2025, 1, 4),
//     ),
//     ProjectItem(
//       name: '4th Project name',
//       projectDescription: 'description',
//       modelName: 'Model name',
//       modelDescription: 'Model description',
//       type: 'Productivity app',
//       typeDescription: 'Dataset description',
//       dateCreated: DateTime(2025, 1, 4),
//     ),
//     ProjectItem(
//       name: '5th Project name',
//       projectDescription: 'description',
//       modelName: 'Model name',
//       modelDescription: 'Model description',
//       type: 'Web app integrations',
//       typeDescription: 'Dataset description',
//       dateCreated: DateTime(2025, 1, 4),
//     ),
//     ProjectItem(
//       name: '6th Project name',
//       projectDescription: 'description',
//       modelName: 'Model name',
//       modelDescription: 'Model description',
//       type: 'Sales CRM',
//       typeDescription: 'Dataset description',
//       dateCreated: DateTime(2025, 1, 4),
//     ),
//     ProjectItem(
//       name: '7th Project name',
//       projectDescription: 'description',
//       modelName: 'Model name',
//       modelDescription: 'Model description',
//       type: 'Automation and workflow',
//       typeDescription: 'Dataset description',
//       dateCreated: DateTime(2025, 1, 4),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<DashboardCubit, DashboardState>(
//       builder: (context, state) {
//         // If filteredProjects is empty, use all projects. Otherwise use filtered
//         final displayProjects =
//             state.filteredProjects.isEmpty && state.searchQuery.isEmpty
//                 ? projects
//                 : state.filteredProjects;

//         return Scaffold(
//           backgroundColor: Colors.grey.shade50,
//           body: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header section
//                 _buildHeader(context),

//                 const SizedBox(height: 24),

//                 // Search and filter bar
//                 _buildSearchBar(context, state),

//                 const SizedBox(height: 24),

//                 // Table header
//                 _buildTableHeader(),

//                 // Project list
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: const BorderRadius.only(
//                         bottomLeft: Radius.circular(8),
//                         bottomRight: Radius.circular(8),
//                       ),
//                       border: Border.all(color: Colors.grey.shade200),
//                     ),
//                     child: ListView.separated(
//                       itemCount: displayProjects.length,
//                       separatorBuilder: (context, index) => Divider(
//                         height: 1,
//                         color: Colors.grey.shade200,
//                       ),
//                       itemBuilder: (context, index) {
//                         return ProjectListItem(project: displayProjects[index]);
//                       },
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Pagination
//                 _buildPagination(context, state),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Projects',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             Text(
//               'View all your projects',
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             OutlinedButton.icon(
//               onPressed: () {},
//               icon: SvgPicture.asset(
//                 AssetsPaths.importIcon,
//                 width: 16,
//                 height: 16,
//                 color: Colors.blue,
//               ),
//               label: const Text('Import'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.blue,
//                 side: BorderSide(color: Colors.blue.shade200),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),
//             const SizedBox(width: 12),
//             CreateNewProjectButton(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchBar(BuildContext context, DashboardState state) {
//     return Row(
//       children: [
//         Expanded(
//           child: SizedBox(
//             height: 40,
//             child: TextField(
//               onChanged: (query) {
//                 context.read<DashboardCubit>().searchProjects(query, projects);
//               },
//               decoration: InputDecoration(
//                 hintText: 'Find a project',
//                 hintStyle: TextStyle(color: Colors.grey.shade500),
//                 prefixIcon:
//                     Icon(Icons.search, size: 20, color: Colors.grey.shade600),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(4),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(4),
//                   borderSide: BorderSide(color: Colors.blue.shade300),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         // removed the filter button for now
//         // Container(
//         //   height: 40,
//         //   width: 40,
//         //   decoration: BoxDecoration(
//         //     color: Colors.white,
//         //     border: Border.all(color: Colors.grey.shade300),
//         //     borderRadius: BorderRadius.circular(4),
//         //   ),
//         //   child: IconButton(
//         //     icon: SvgPicture.asset(
//         //       'assets/icons/filter.svg',
//         //       width: 16,
//         //       height: 16,
//         //       color: Colors.grey.shade700,
//         //     ),
//         //     onPressed: () {},
//         //     padding: EdgeInsets.zero,
//         //     tooltip: 'Filter projects',
//         //   ),
//         // ),
//       ],
//     );
//   }

//   Widget _buildTableHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(8),
//           topRight: Radius.circular(8),
//         ),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 40), // Checkbox space
//           Expanded(
//             flex: 2,
//             child: Text(
//               'Name',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               'Model',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               'Type', // Corrected from 'Model' to 'Type' as per previous discussion
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               'Created',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//                 fontSize: 13,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPagination(BuildContext context, DashboardState state) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         TextButton.icon(
//           onPressed: state.currentPage > 1
//               ? () =>
//                   context.read<DashboardCubit>().goToPage(state.currentPage - 1)
//               : null,
//           icon: const Icon(Icons.arrow_back_ios, size: 14),
//           label: const Text('Previous'),
//           style: TextButton.styleFrom(
//             foregroundColor: Colors.grey.shade700,
//           ),
//         ),
//         Row(
//           children: [
//             for (int i = 1; i <= 3; i++)
//               _pageButton(context, i, state.currentPage),
//             if (state.currentPage > 4)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child:
//                     Text('...', style: TextStyle(color: Colors.grey.shade600)),
//               ),
//             if (state.currentPage >= 4 && state.currentPage <= 7)
//               for (int i = 4; i <= 7; i++)
//                 _pageButton(context, i, state.currentPage),
//             if (state.currentPage < 4 || state.currentPage > 7)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child:
//                     Text('...', style: TextStyle(color: Colors.grey.shade600)),
//               ),
//             for (int i = 8; i <= 10; i++)
//               _pageButton(context, i, state.currentPage),
//           ],
//         ),
//         TextButton(
//           onPressed: state.currentPage < 10
//               ? () =>
//                   context.read<DashboardCubit>().goToPage(state.currentPage + 1)
//               : null,
//           style: TextButton.styleFrom(
//             foregroundColor: Colors.grey.shade700,
//           ),
//           child: const Row(
//             children: [
//               Text('Next'),
//               SizedBox(width: 4),
//               Icon(Icons.arrow_forward_ios, size: 14),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _pageButton(BuildContext context, int page, int currentPage) {
//     final isActive = page == currentPage;

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       child: InkWell(
//         onTap: () => context.read<DashboardCubit>().goToPage(page),
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: isActive ? Colors.blue : Colors.transparent,
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Text(
//               page.toString(),
//               style: TextStyle(
//                 color: isActive ? Colors.white : Colors.grey.shade800,
//                 fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ProjectListItem extends StatelessWidget {
//   final ProjectItem project;

//   const ProjectListItem({required this.project, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         child: Row(
//           children: [
//             SizedBox(
//               width: 40,
//               child: Checkbox(
//                 value: false,
//                 onChanged: (_) {},
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     project.name,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     project.projectDescription,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     project.modelName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     project.modelDescription,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     project.type,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     project.typeDescription,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Text(
//                 _formatDate(project.dateCreated),
//                 style: TextStyle(
//                   color: Colors.grey.shade700,
//                 ),
//                 textAlign: TextAlign.right,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return '${months[date.month - 1]} ${date.day}, ${date.year}';
//   }
// }

// class ProjectItem {
//   final String name;
//   final String projectDescription;
//   final String modelName;
//   final String modelDescription;
//   final String type;
//   final String typeDescription;
//   final DateTime dateCreated;

//   ProjectItem({
//     required this.name,
//     required this.projectDescription,
//     required this.modelName,
//     required this.modelDescription,
//     required this.type,
//     required this.typeDescription,
//     required this.dateCreated,
//   });
// }
