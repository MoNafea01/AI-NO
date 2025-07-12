class RegisterResponseModel {
  final String message;
  final String access;
  final String refresh;

  RegisterResponseModel(
      {required this.message, required this.access, required this.refresh});

  Map<String, dynamic> toJson() => {
        'message': message,
        'access': access,
        'refresh': refresh,
      };

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'] ?? '',
      access: json['access'] ?? '',
      refresh: json['refresh'] ?? '',
    );
  }

}
