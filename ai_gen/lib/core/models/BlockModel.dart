class BlockModel {
  num? id;
  String? nodeName;
  String? nodeType;
  String? task;
  List<Map<String, dynamic>>? params;
  List<String>? inputDots;
  List<String>? outputDots;
  String? apiCall;

  BlockModel({
    this.id,
    this.nodeName,
    this.nodeType,
    this.task,
    this.params,
    this.inputDots,
    this.outputDots,
    this.apiCall,
  });

  BlockModel.fromJson(dynamic json) {
    id = json['id'];
    nodeName = json['node_name'];
    nodeType = json['node_type'];
    task = json['task'];
    params = json['params'];
    inputDots =
        json['output_dots'] != null ? json['output_dots'].cast<String>() : [];
    outputDots =
        json['output_dots'] != null ? json['output_dots'].cast<String>() : [];
    apiCall = json['api_call'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['node_name'] = nodeName;
    map['node_type'] = nodeType;
    map['task'] = task;
    map['params'] = params;
    map['input_dots'] = inputDots;
    map['output_dots'] = outputDots;
    map['api_call'] = apiCall;
    return map;
  }
}
