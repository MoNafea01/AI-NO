import 'package:ai_gen/core/helper/helper.dart';

enum ParameterType {
  string,
  number,
  list,
  boolean,
  dropDownList,
  directory,
}

class ParameterModel {
  String name;
  String? _type;
  dynamic _value;
  dynamic _defaultValue;
  final List? choices;

  ParameterModel({
    this.name = 'param_name',
    this.choices = const [],
    String? type,
    dynamic defaultValue,
  })  : _type = type,
        _defaultValue = defaultValue,
        _value = defaultValue;

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
      case 'list':
        return ParameterType.list;
      case 'bool':
        return ParameterType.boolean;
      default:
        return _type;
    }
  }

  get value => _value;

  set value(dynamic newValue) {
    if (type == ParameterType.list) {
      _value = Helper.parseList(newValue);
    } else {
      _value = newValue;
    }
  }

  Map<String, dynamic> toJson() => {name: _value};

  @override
  String toString() {
    return '{$name: $value ($_type)}';
  }
}
