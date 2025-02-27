class Params {
  String name;
  String? type;
  dynamic value;

  Params({
    this.name = 'param_name',
    this.type,
    this.value,
  });

  Params.fromJson(dynamic json) : name = json['name'] ?? 'param_name' {
    type = json['type'];
    value = json['default'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['type'] = type;
    map['default'] = value;
    return map;
  }

  @override
  String toString() {
    return '{$name: $value ($type)}';
  }
}
