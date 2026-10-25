class UserModel {
  final int id;
  final String userCode;
  final String name;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.userCode,
    required this.name,
    this.role = 'STK Mukto',
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userCode: json['userCode']?.toString() ?? json['user_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'STK Mukto',
      isActive: json['isActive'] == true || json['is_active'] == 1 || json['isActive'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userCode': userCode,
      'name': name,
      'role': role,
      'isActive': isActive,
    };
  }

  String get displayName {
    if (userCode.isNotEmpty) {
      return '[$userCode] $name';
    }
    return name;
  }
}
