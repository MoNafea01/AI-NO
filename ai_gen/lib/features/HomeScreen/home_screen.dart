import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit.dart';
import 'package:ai_gen/features/HomeScreen/profile_screen.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/create_new_project_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: isExpanded ? 200 : 90,
            color: Colors.blue.shade100,
            child: Column(
              children: [
                _buildSidebar(),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: ProjectsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                if (isExpanded) const SizedBox(width: 8),
                if (isExpanded)
                  const Text(
                    'Model Craft',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                // const Spacer(),
                IconButton(
                  icon: Icon(
                      isExpanded ? Icons.chevron_left : Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sidebarItem(Icons.explore, 'Explore', true),
            _sidebarItem(Icons.architecture, 'Architectures', false),
            _sidebarItem(Icons.model_training, 'Models', false),
            _sidebarItem(Icons.dataset, 'Datasets', false),
            _sidebarItem(Icons.school, 'Learn', false),
            _sidebarItem(Icons.description, 'Docs', false),
            _sidebarItem(Icons.settings, 'Settings', false),
            const Spacer(),
            const ProfileWidget(),
            const SizedBox(height: 10),
            _logoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : Colors.black87),
        title: isExpanded
            ? Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                ),
              )
            : null,
        minLeadingWidth: 20,
        dense: true,
        onTap: () {},
      ),
    );
  }

  Widget _logoutButton() {
    return InkWell(
      onTap: () {
        Provider.of<AuthProvider>(context, listen: false).logout(context);

      },
      child: Row(
        children: [
          const Icon(Icons.logout, color: Colors.red),
          if (isExpanded) const SizedBox(width: 8),
          if (isExpanded)
            const Text(
              'Log out',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<AuthProvider>().userProfile;
    //final authProvider = Provider.of<AuthProvider>(context);
    final userName = userProfile?.username ;
    // final firstName = userProfile?.firstName;
    final email = userProfile?.email;
   


    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
         Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(child: const Text("profile"),
          onTap: () {
              context.read<ProfileCubit>().loadProfile();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ),
        Row(
          children: [
             const CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 16,
              child: Text( '',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text(
                    userName ?? 'username',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    email ?? 'example@gmail.com',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProjectsScreen extends StatelessWidget {
  ProjectsScreen({super.key});

  final List<ProjectItem> projects = [
    ProjectItem(
      name: 'Content curating app',
      projectDescription: 'Project description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Content curating app',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: 'Design software',
      projectDescription: 'Project description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Design software',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: 'Data prediction',
      projectDescription: 'Project description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Data prediction',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: 'Productivity app',
      projectDescription: 'Project description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Productivity app',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: 'Web app integrations',
      projectDescription: 'Project description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Web app integrations',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: 'Sales CRM',
      projectDescription: 'Project description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Sales CRM',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: 'Automation and workflow',
      projectDescription: 'Project description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Automation and workflow',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: 'Automation and workflow',
      projectDescription: 'Project description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Automation and workflow',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Projects',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'View all your projects',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const CreateNewProjectButton(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40, // Making search field smaller
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Find a project',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, size: 20),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Model',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Model',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Created',
                      style: TextStyle(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return ProjectListItem(project: projects[index]);
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                Row(
                  children: [
                    _pageButton('1', true),
                    _pageButton('2', false),
                    _pageButton('3', false),
                    const Text('...'),
                    _pageButton('8', false),
                    _pageButton('9', false),
                    _pageButton('10', false),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Row(
                    children: [
                      Text('Next'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _pageButton(String text, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: isActive ? Colors.blue : Colors.transparent,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class ProjectListItem extends StatelessWidget {
  final ProjectItem project;

  const ProjectListItem({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project name',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'description',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.modelName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  project.modelDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.type,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  project.typeDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(project.dateCreated),
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class ProjectItem {
  final String name;
  final String projectDescription;
  final String modelName;
  final String modelDescription;
  final String type;
  final String typeDescription;
  final DateTime dateCreated;

  ProjectItem({
    required this.name,
    required this.projectDescription,
    required this.modelName,
    required this.modelDescription,
    required this.type,
    required this.typeDescription,
    required this.dateCreated,
  });
}
