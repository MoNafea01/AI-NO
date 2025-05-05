import 'package:ai_gen/core/helper/helper.dart';

enum ParameterType {
  string,
  int,
  double,
  listInt,
  listString,
  boolean,
  dropDownList,
  path,
}

class ParameterModel {
  String name;
  String? _type;
  dynamic _value;
  final dynamic _defaultValue;
  final List? choices;
  final List? allowedExtensions;

  ParameterModel({
    this.name = 'param_name',
    this.choices,
    String? type,
    dynamic defaultValue,
    dynamic value,
    this.allowedExtensions,
  })  : _type = type,
        _defaultValue = defaultValue {
    if (value != null) {
      _value = value;
    } else if (defaultValue is List) {
      _value = [...defaultValue];
    } else {
      _value = defaultValue;
    }
  }

  get defaultValue => _defaultValue;

  ParameterModel copyWith({
    String? name,
    String? type,
    defaultValue,
    List? choices,
    dynamic value,
  }) {
    return ParameterModel(
      name: name ?? this.name,
      type: type ?? _type,
      defaultValue: defaultValue ?? _defaultValue,
      choices: choices ?? this.choices,
      value: value ?? _value,
      allowedExtensions: allowedExtensions,
    );
  }

  factory ParameterModel.fromJson(json) {
    return ParameterModel(
      name: json['name'] ?? 'Parameter',
      type: json['type'],
      defaultValue: json['default'],
      choices: json['choices'] as List? ?? [],
      allowedExtensions: json['extensions'] as List? ?? [],
    );
  }

  get type {
    print('$name parameter type: $_type, choices: $choices');
    switch (_type) {
      case 'str':
        return (choices != null && choices!.isNotEmpty)
            ? ParameterType.dropDownList
            : ParameterType.string;

      case 'int':
        return ParameterType.int;
      case 'float':
        return ParameterType.double;
      case 'list_int':
        return ParameterType.listInt;
      case 'list_str':
        return ParameterType.listString;
      case 'bool':
        return ParameterType.boolean;
      case 'path':
        return ParameterType.path;
      default:
        return ParameterType.string;
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
      case ParameterType.listInt:
        _value = Helper.parseIntList(newValue);
        break;
      case ParameterType.boolean:
        _value = newValue == 'true' || newValue == true;
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
      default:
        _value = newValue;
    }
  }

  void resetValue() {
    if (_defaultValue is List) {
      _value = _value = [..._defaultValue];
    } else {
      _value = _defaultValue;
    }
  }

  Map<String, dynamic> toJson() => {name: _value};

  @override
  String toString() {
    return '{$name: $value ($_type)}';
  }

  /// This method is used to print the types of parameters
  /// call this in the constructor
  /// the last types used{float: 30, str: 24, int: 12, list_int: 10, list_str: 2}
// static final Map<String, int> _typesMap = {};
// void _printNodeTypes() {
//   if (type != null) {
//     if (_typesMap.containsKey(type)) {
//       _typesMap[type] = _typesMap[type]! + 1;
//     } else {
//       _typesMap[type] = 1;
//     }
//     print(_typesMap);
//   }
// }
}
