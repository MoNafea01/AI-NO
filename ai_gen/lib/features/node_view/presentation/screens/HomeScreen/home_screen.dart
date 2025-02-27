import 'package:ai_gen/features/node_view/presentation/grid_loader.dart';
import 'package:ai_gen/features/node_view/presentation/screens/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';

class ProjectsDashboard extends StatelessWidget {
  const ProjectsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 80,
            color: const Color(0xfff2f2f2),
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
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage("assets/profile.jpg"),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GridLoader()));
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Projects",
                    style: TextStyle(
                        fontSize: 30,
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
                            hintText: "Search for projects",
                            hintStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: const Color(0xfff2f2f2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.upload,
                          color: Colors.black,
                        ),
                        label: const Text("Import"),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.download,
                          color: Colors.black,
                        ),
                        label: const Text("Export"),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "New Project",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Projects Table
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("Model")),
                            DataColumn(label: Text("Dataset")),
                            DataColumn(label: Text("Created")),
                          ],
                          rows: List.generate(
                            10,
                            (index) => const DataRow(cells: [
                              DataCell(Text("Customer Sentiment Classifier")),
                              DataCell(Text("BERT v3.1")),
                              DataCell(Text("Customer Reviews Dataset v2.0")),
                              DataCell(Text("Oct 20, 2024")),
                            ]),
                          ),
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
