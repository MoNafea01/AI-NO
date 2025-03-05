import 'Params.dart';

class NodeModel {
  num? id;
  int? index;
  String name;
  String? displayName;
  String category;
  String type;
  String task;
  List<Params>? params;
  List<String>? inputDots;
  List<String>? outputDots;
  String? apiCall;

  NodeModel({
    this.id,
    this.name = "Node",
    this.displayName,
    this.category = "others",
    this.type = "others",
    this.task = "others",
    this.params,
    this.inputDots,
    this.outputDots,
    this.apiCall,
  });

  NodeModel.fromJson(dynamic json)
      : name = json['node_name'] ?? "Node",
        category = json['category'] ?? "cat ${json['id']}",
        type = json['node_type'] ?? "type ${json['id']}",
        task = json['task'] ?? "task ${json['id']}" {
    if (json['id'] != null) id = num.parse(json['id'].toString());
    if (json['idx'] != null) index = int.parse(json['idx'].toString());

    displayName = json['display_name'] ?? name;

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
    json['display_name'] = displayName;
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
