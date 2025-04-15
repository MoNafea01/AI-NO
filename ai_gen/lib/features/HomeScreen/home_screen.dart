import 'package:flutter/material.dart';

class ProjectsDashboard extends StatefulWidget {
  const ProjectsDashboard({super.key});

  @override
  State<ProjectsDashboard> createState() => _ProjectsDashboardState();
}

class _ProjectsDashboardState extends State<ProjectsDashboard> {
  bool _isExpanded = false; // Controls sidebar state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: Row(
        children: [
          // Sidebar (Collapsible Drawer)
          MouseRegion(
            onEnter: (_) => setState(() => _isExpanded = true),
            onExit: (_) => setState(() => _isExpanded = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isExpanded ? 250 : 80, // Expand width dynamically
              decoration: const BoxDecoration(
                color: Color(0xfff2f2f2),
                border: Border(
                  right: BorderSide(color: Colors.black, width: 0.7),
                  left: BorderSide(color: Colors.black, width: 1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const SidebarIconApp(
                          iconPath: "assets/images/ProjectLogo.png"),
                      const SizedBox(height: 20),
                      _isExpanded
                          ? const Text("Collapse",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))
                          : SidebarItem(
                              iconPath: "assets/images/Icon.png",
                              label: "Models",
                              expanded: _isExpanded),
                      const SizedBox(height: 20),

                      // SidebarItem(
                      //     iconPath: "assets/images/Schema.png",
                      //     label: "Architectures",
                      //     expanded: _isExpanded),

                      SidebarItem(
                          iconPath: "assets/images/network_nodes.png",
                          label: "Models",
                          expanded: _isExpanded),

                      SidebarItem(
                          iconPath: "assets/images/data_sets.png",
                          label: "Datasets",
                          expanded: _isExpanded),
                      SidebarItem(
                          iconPath: "assets/images/school.png",
                          label: "Learn",
                          expanded: _isExpanded),

                      SidebarItem(
                          iconPath: "assets/images/docs.png",
                          label: "Docs",
                          expanded: _isExpanded),
                      SidebarItem(
                          iconPath: "assets/images/settings.png",
                          label: "Settings",
                          expanded: _isExpanded),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Profile",
                          style: TextStyle(
                              color: Color(0xff64748B), fontSize: 16)),
                      const SizedBox(height: 10),
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            AssetImage("assets/images/profileImage.png"),
                      ),
                      const SizedBox(height: 10),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Projects",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 14, 14, 14)),
                  ),
                  const SizedBox(height: 5),
                  const Text("View all your projects.",
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 20),

                  // Search & Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            hintText: "Search for projects",
                            hintStyle: const TextStyle(color: Colors.black),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.black),
                            filled: true,
                            fillColor: const Color(0x00666666),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // CustomIconTextButton(
                      //   text: "Import",
                      //   icon: Icons.upload,
                      //   backgroundColor: const Color(0xfff2f2f2),
                      //   textColor: Colors.black,
                      //   iconColor: Colors.black,
                      //   onTap: () {},
                      // ),
                      // const SizedBox(width: 10),
                      // CustomIconTextButton(
                      //   text: "Export",
                      //   icon: Icons.download,
                      //   backgroundColor: const Color(0xfff2f2f2),
                      //   textColor: Colors.black,
                      //   iconColor: Colors.black,
                      //   onTap: () {},
                      // ),
                      // const SizedBox(width: 10),
                      // CustomIconTextButton(
                      //   text: "New Project",
                      //   icon: Icons.add,
                      //   backgroundColor: Colors.blue,
                      //   textColor: Colors.white,
                      //   iconColor: Colors.white,
                      //   onTap: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => const GridLoader()));
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Projects Table
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth),
                                child: DataTable(
                                  columnSpacing: 20,
                                  dataRowMinHeight: 50,
                                  dataRowMaxHeight: 60,
                                  headingRowColor: WidgetStateColor.resolveWith(
                                    (states) => const Color(
                                        0xFFE9EAEB), // Your desired background color
                                  ),
                                  columns: const [
                                    DataColumn(
                                        label: Expanded(
                                            child: Text("Name",
                                                textAlign: TextAlign.center))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Text("Model",
                                                textAlign: TextAlign.center))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Text("Dataset",
                                                textAlign: TextAlign.center))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Text("Created",
                                                textAlign: TextAlign.center))),
                                  ],
                                  rows: projects.map((project) {
                                    return DataRow(cells: [
                                      DataCell(
                                          Center(child: Text(project.name))),
                                      DataCell(
                                          Center(child: Text(project.model))),
                                      DataCell(
                                          Center(child: Text(project.dataset))),
                                      DataCell(Center(
                                          child: Text(project.createdDate))),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sidebar Icon Item
class SidebarItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool expanded;
  final bool isLogout;

  const SidebarItem({
    super.key,
    required this.iconPath,
    required this.label,
    required this.expanded,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, height: 24, width: 24),
          if (expanded) ...[
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLogout ? Colors.redAccent : Colors.black,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// Sidebar Icon with Image (Used for the App Logo)
class SidebarIconApp extends StatelessWidget {
  final String iconPath;

  const SidebarIconApp({super.key, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        child: Image.asset(
          iconPath,
          height: 40,
          width: 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class Project {
  final String name;
  final String model;
  final String dataset;
  final String createdDate;

  Project({
    required this.name,
    required this.model,
    required this.dataset,
    required this.createdDate,
  });
}

List<Project> projects = List.generate(
  50,
  (index) => Project(
    name: "Project $index",
    model: "BERT v3.$index",
    dataset: "Customer Reviews Dataset v2.0",
    createdDate: "Oct 20, 2024",
  ),
);

/*

class SidebarItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool expanded;
  final bool isLogout;

  const SidebarItem({
    super.key,
    required this.iconPath,
    required this.label,
    required this.expanded,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, height: 24, width: 24),
          if (expanded) ...[
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isLogout ? Colors.redAccent : Colors.black,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// Sidebar Icon with Image (For App Logo)
class SidebarIconApp extends StatelessWidget {
  final String iconPath;

  const SidebarIconApp({super.key, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        child: Image.asset(
          iconPath,
          height: 40,
          width: 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}


*/
