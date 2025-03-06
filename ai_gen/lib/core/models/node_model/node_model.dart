import 'Params.dart';

class NodeModel {
  num? id;
  dynamic nodeId;
  int? index;
  String name;
  String? displayName;
  String? description;
  String category;
  String type;
  String task;
  List<Params>? params;
  List<String>? inputDots;
  List<String>? outputDots;
  String? apiCall;

  NodeModel({
    this.id,
    this.index,
    this.name = "Node",
    this.displayName,
    this.description,
    this.category = "others",
    this.type = "others",
    this.task = "others",
    this.params,
    this.inputDots,
    this.outputDots,
    this.apiCall,
  });

  NodeModel copyWith({
    num? id,
    dynamic nodeId,
    int? index,
    String? name,
    String? displayName,
    String? category,
    String? type,
    String? task,
    List<Params>? params,
    List<String>? inputDots,
    List<String>? outputDots,
    String? apiCall,
  }) {
    return NodeModel(
      id: id ?? this.id,
      index: index ?? this.index,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description,
      category: category ?? this.category,
      type: type ?? this.type,
      task: task ?? this.task,
      params: params ?? this.params,
      inputDots: inputDots ?? this.inputDots,
      outputDots: outputDots ?? this.outputDots,
      apiCall: apiCall ?? this.apiCall,
    );
  }

  NodeModel.fromJson(dynamic json)
      : name = json['node_name'] ?? "Node",
        category = json['category'] ?? "cat ${json['id']}",
        type = json['node_type'] ?? "type ${json['id']}",
        task = json['task'] ?? "task ${json['id']}" {
    if (json['id'] != null) id = num.parse(json['id'].toString());
    if (json['idx'] != null) index = int.parse(json['idx'].toString());

    displayName = json['displayed_name'] ?? name;
    description = json['description'];

    if (json['params'] != null) {
      params = (json['params'] as List)
          .map((e) => Params.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    inputDots = json['input_channels'] != null
        ? json['input_channels'].cast<String>()
        : [];
    outputDots = json['output_channels'] != null
        ? json['output_channels'].cast<String>()
        : [];
    apiCall = json['api_call'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['idx'] = index;
    json['node_name'] = name;
    json['displayed_name'] = displayName;
    json['description'] = description;
    json['category'] = category;
    json['node_type'] = type;
    json['task'] = task;
    json['params'] = params?.map((e) => e.toJson()).toList();
    json['input_channels'] = inputDots;
    json['output_channels'] = outputDots;
    json['api_call'] = apiCall;
    return json;
  }

  // to be used in the API call as the api data
  Map<String, dynamic> get paramsToJson {
    Map<String, dynamic> paramsMap = {};
    params?.forEach((param) => paramsMap[param.name] = param.value);

    return paramsMap;
  }
}
