enum ParameterType {
  string,
  number,
  boolean,
}

class ParameterModel {
  String name;
  String? _type;
  dynamic value;
  dynamic _defaultValue;

  ParameterModel({
    this.name = 'param_name',
    String? type,
    dynamic defaultValue,
  })  : _type = type,
        _defaultValue = defaultValue,
        value = defaultValue;

  get defaultValue => _defaultValue;

  ParameterModel.fromJson(dynamic json) : name = json['name'] ?? 'param_name' {
    _type = json['type'];
    _defaultValue = json['default'];
    value = json['default'];
  }

  get type {
    switch (_type) {
      case 'str':
        return ParameterType.string;
      case 'float':
        return ParameterType.number;
      case 'bool':
        return ParameterType.boolean;
      default:
        return _type;
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['type'] = _type;
    map['default'] = value;
    return map;
  }

  @override
  String toString() {
    return '{$name: $value ($_type)}';
  }
}
