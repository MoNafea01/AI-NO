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
