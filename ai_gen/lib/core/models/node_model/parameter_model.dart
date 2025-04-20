enum ParameterType {
  string,
  number,
  boolean,
  dropDownList,
}

class ParameterModel {
  String name;
  String? _type;
  dynamic value;
  dynamic _defaultValue;
  final List? choices;

  ParameterModel({
    this.name = 'param_name',
    this.choices = const [],
    String? type,
    dynamic defaultValue,
  })  : _type = type,
        _defaultValue = defaultValue,
        value = defaultValue;

  get defaultValue => _defaultValue;

  ParameterModel copyWith({
    String? name,
    String? type,
    dynamic defaultValue,
    List? choices,
  }) {
    return ParameterModel(
      name: name ?? this.name,
      type: type ?? _type,
      defaultValue: defaultValue ?? _defaultValue,
      choices: choices ?? this.choices,
    );
  }

  factory ParameterModel.fromJson(dynamic json) {
    print(json['choices']);
    return ParameterModel(
      name: json['name'] ?? 'Parameter',
      type: json['type'],
      defaultValue: json['default'],
      choices: json['choices'] as List? ?? [],
    );
  }

  get type {
    if (choices != null && choices!.isNotEmpty) {
      return ParameterType.dropDownList;
    }

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
