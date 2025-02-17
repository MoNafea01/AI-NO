class Params {
  String? name;
  String? type;
  dynamic defaultValue;

  Params({
    this.name,
    this.type,
    this.defaultValue,
  });

  Params.fromJson(dynamic json) {
    name = json['name'];
    type = json['type'];
    defaultValue = json['default'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['type'] = type;
    map['default'] = defaultValue;
    return map;
  }
}
