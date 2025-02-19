import 'Params.dart';

class BlockModel {
  num? id;
  int? index;
  String? nodeName;
  String? displayName;
  String category;
  String nodeType;
  String task;
  List<Params>? params;
  List<String>? inputDots;
  List<String>? outputDots;
  String? apiCall;

  BlockModel({
    this.id,
    this.nodeName,
    this.displayName,
    this.category = "others",
    this.nodeType = "others",
    this.task = "others",
    this.params,
    this.inputDots,
    this.outputDots,
    this.apiCall,
  });

  BlockModel.fromJson(dynamic json)
      : category = json['category'] ?? "cat ${json['id']}",
        nodeType = json['node_type'] ?? "type ${json['id']}",
        task = json['task'] ?? "task ${json['id']}" {
    if (json['id'] != null) id = num.parse(json['id'].toString());
    if (json['idx'] != null) index = int.parse(json['idx'].toString());
    nodeName = json['node_name'] ?? "Node";
    displayName = json['display_name'] ?? nodeName;

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
    json['node_name'] = nodeName;
    json['display_name'] = displayName;
    json['category'] = category;
    json['node_type'] = nodeType;
    json['task'] = task;
    json['params'] = params?.map((e) => e.toJson()).toList();
    json['input_channels'] = inputDots;
    json['output_channels'] = outputDots;
    json['api_call'] = apiCall;
    return json;
  }
}
