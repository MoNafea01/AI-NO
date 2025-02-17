import 'Params.dart';

class BlockModel {
  num? id;
  String? nodeType;
  String? task;
  String? nodeName;
  List<Params?>? params;
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
    id = num.parse(json['id'].toString());
    nodeType = json['node_type'];
    task = json['task'];
    nodeName = json['node_name'];

    if (json['params'] != null) {
      params = (json['params'] as List)
          .map((e) => Params.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    inputDots =
        json['input_dots'] != null ? json['input_dots'].cast<String>() : [];
    outputDots =
        json['output_dots'] != null ? json['output_dots'].cast<String>() : [];
    apiCall = json['api_call'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['node_type'] = nodeType;
    json['task'] = task;
    json['node_name'] = nodeName;
    json['params'] = params?.map((e) => e?.toJson()).toList();
    json['input_dots'] = inputDots;
    json['output_dots'] = outputDots;
    json['api_call'] = apiCall;
    return json;
  }
}
