// Projects Table Widget
import 'package:flutter/material.dart';

class ProjectsTable extends StatelessWidget {
  const ProjectsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columnSpacing: 20,
                  dataRowMinHeight: 50,
                  dataRowMaxHeight: 60,
                  columns: const [
                    DataColumn(
                        label: Expanded(
                            child: Text("Name", textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child: Text("Model", textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child:
                                Text("Dataset", textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child:
                                Text("Created", textAlign: TextAlign.center))),
                  ],
                  rows: List.generate(
                    50,
                    (index) => DataRow(cells: [
                      DataCell(Center(child: Text("Project $index"))),
                      const DataCell(Center(child: Text("BERT v3.1"))),
                      const DataCell(
                          Center(child: Text("Customer Reviews Dataset v2.0"))),
                      const DataCell(Center(child: Text("Oct 20, 2024"))),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
