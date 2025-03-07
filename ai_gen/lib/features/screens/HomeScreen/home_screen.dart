import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:ai_gen/node_package/widgets/Resuable%20Widgets/custom_text_icon_button.dart';
import 'package:flutter/material.dart';

class ProjectsDashboard extends StatelessWidget {
  const ProjectsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    // if (screenWidth < 800 || screenHeight < 500) {
    //   return const SmallScreenWarning();
    // }
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 80,
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
                    IconButton(
                      icon: const Icon(Icons.menu,
                          color: Color.fromARGB(255, 19, 18, 18)),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 20),
                    const SidebarIcon(icon: Icons.dashboard),
                    const SidebarIcon(icon: Icons.search),
                    const SidebarIcon(icon: Icons.settings),
                    const SidebarIcon(icon: Icons.folder),
                    const SidebarIcon(icon: Icons.insert_chart),
                  ],
                ),
                Column(
                  children: [
                    const Text("Profile",
                        style:
                            TextStyle(color: Color(0xff64748B), fontSize: 16)),
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
                  const Text(
                    "View all your projects.",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 20),

                  // Search & Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Colors.black), // الإطار في الحالة العادية
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black), // الإطار عند التركيز
                            ),
                            hintText: "Search for projects",
                            hintStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
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
                      CustomIconTextButton(
                        text: "Import",
                        icon: Icons.upload,
                        backgroundColor: const Color(0xfff2f2f2),
                        textColor: const Color.fromARGB(255, 15, 14, 14),
                        iconColor: const Color.fromARGB(255, 7, 7, 7),
                        onTap: () {},
                      ),
                      const SizedBox(width: 10),
                      CustomIconTextButton(
                        text: "Export",
                        icon: Icons.download,
                        backgroundColor: const Color(0xfff2f2f2),
                        textColor: const Color.fromARGB(255, 15, 14, 14),
                        iconColor: const Color.fromARGB(255, 7, 7, 7),
                        onTap: () {},
                      ),
                      const SizedBox(width: 10),
                      CustomIconTextButton(
                        text: "New Project",
                        icon: Icons.add,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NodeView()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Projects Table
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: SingleChildScrollView(
                        scrollDirection:
                            Axis.vertical, // Enable vertical scrolling
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis
                                  .horizontal, // Enable horizontal scrolling if needed
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth:
                                        constraints.maxWidth), // Stretch table
                                child: DataTable(
                                  columnSpacing: 20, // Adjust spacing
                                  dataRowMinHeight: 50,
                                  dataRowMaxHeight: 60,
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
                                  rows: List.generate(
                                    50, // More rows for testing
                                    (index) => DataRow(cells: [
                                      DataCell(Center(
                                          child: Text("Project $index"))),
                                      const DataCell(
                                          Center(child: Text("BERT v3.1"))),
                                      const DataCell(Center(
                                          child: Text(
                                              "Customer Reviews Dataset v2.0"))),
                                      const DataCell(
                                          Center(child: Text("Oct 20, 2024"))),
                                    ]),
                                  ),
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

// Sidebar Icon Widget
class SidebarIcon extends StatelessWidget {
  final IconData icon;

  const SidebarIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: IconButton(
        icon: Icon(icon, color: const Color.fromARGB(255, 10, 10, 10)),
        onPressed: () {},
      ),
    );
  }
}

class SidebarIconApp extends StatelessWidget {
  final String iconPath;

  const SidebarIconApp({super.key, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ClipRRect(
          child: Image.asset(iconPath, height: 35, width: 35),
        )

        //Image.asset("assets/images/ProjectLogo.png"),
        );
  }
}
