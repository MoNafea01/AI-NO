import 'Params.dart';

class BlockModel {
  num? id;
  String? nodeName;
  String? nodeType;
  String? task;
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
    id = json['id'];
    nodeName = json['node_name'];
    nodeType = json['node_type'];
    task = json['task'];

    if (json['params'] != null) {
      params = (json['params'] as List)
          .map((e) => Params.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // params = (json['params']?.map((e) => Params.fromJson(e)).toList())
    //     as List<Params>?;

    inputDots =
        json['output_dots'] != null ? json['output_dots'].cast<String>() : [];
    outputDots =
        json['output_dots'] != null ? json['output_dots'].cast<String>() : [];
    apiCall = json['api_call'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['node_name'] = nodeName;
    json['node_type'] = nodeType;
    json['task'] = task;
    json['params'] = params?.map((e) => e?.toJson()).toList();
    json['input_dots'] = inputDots;
    json['output_dots'] = outputDots;
    json['api_call'] = apiCall;
    return json;
  }
}
