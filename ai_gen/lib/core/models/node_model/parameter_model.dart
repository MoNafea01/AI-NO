import 'package:ai_gen/core/helper/helper.dart';

enum ParameterType {
  string,
  int,
  double,
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
      case 'int':
        return ParameterType.int;
      case 'float':
        return ParameterType.double;
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
    switch (type) {
      case ParameterType.string:
        _value = newValue.toString();
        break;
      case ParameterType.int:
        _value = int.tryParse(newValue.toString()) ?? 0;
        break;
      case ParameterType.double:
        if (newValue is String) {
          _value = double.tryParse(newValue)?.toStringAsFixed(2) ?? 0.0;
          _value = double.parse(_value);
        } else if (newValue is double) {
          _value = double.parse(newValue.toStringAsFixed(2));
        } else {
          _value = 0.0;
        }
        break;
      case ParameterType.list:
        _value = Helper.parseList(newValue);
        break;
      case ParameterType.boolean:
        _value = newValue == 'true' || newValue == true;
        break;
      default:
        _value = newValue;
    }
  }

  Map<String, dynamic> toJson() => {name: _value};

  @override
  String toString() {
    return '{$name: $value ($_type)}';
  }
}
