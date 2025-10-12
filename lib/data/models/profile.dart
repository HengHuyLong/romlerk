// lib/data/models/profile.dart

class Profile {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Other',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
      };
}
