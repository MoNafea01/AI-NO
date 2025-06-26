class ProjectModel {
  ProjectModel({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.path,
  });

  int? id;
  String? name;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? path;
  ProjectModel.fromJson(json) {
    id = json['id'];
    name = json['project_name'];
    description = json['project_description'];
    createdAt =
        json['created_at'] != null ? DateTime.parse(json['created_at']) : null;
    updatedAt =
        json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null;
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['project_name'] = name;
    map['project_description'] = description;
    map['created_at'] = createdAt
        ?.toIso8601String(); // Convert to ISO 8601 string but i want to keep the date format
    // map['created_at'] = createdAt?.toString(); // Keep the date format
    map['updated_at'] = updatedAt?.toIso8601String();
    map['path'] = path;
    return map;
  }
}
