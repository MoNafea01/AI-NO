class AIModel {
  String? message;
  String? modelName;
  String? modelType;
  String? task;
  Map<String, dynamic>? params;
  int? modelId;

  AIModel({
    this.message,
    this.params,
    required this.modelName,
    required this.modelType,
    required this.task,
    this.modelId,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      message: json['message'],
      params: json['params'],
      modelName: json['node_name'],
      modelType: json['node_type'],
      task: json['task'],
      modelId: json['node_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'params': params ?? {},
        'node_name': modelName,
        'node_type': modelType,
        'task': task,
        'node_id': modelId,
      };

  Map<String, dynamic> createModelToJson() => {
        'model_name': modelName,
        'model_type': modelType,
        'task': task,
        'params': params ?? {},
      };

  @override
  String toString() {
    // TODO: implement toString
    return 'AIModel: $modelId';
  }
}
