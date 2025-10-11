class UserModel {
  final String uid;
  final String? phone;
  final String? name;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    this.phone,
    this.name,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? s) => (s == null) ? null : DateTime.tryParse(s);
    return UserModel(
      uid: json['uid'] as String,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      createdAt: parseDate(json['createdAt'] as String?),
      lastLoginAt: parseDate(json['lastLoginAt'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'phone': phone,
        'name': name,
        'createdAt': createdAt?.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
      };
}
