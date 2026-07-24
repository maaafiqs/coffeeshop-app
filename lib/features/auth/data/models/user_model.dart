class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role; // 'customer' or 'admin'
  final int points;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'customer',
    this.points = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'points': points,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'customer',
      points: (map['points'] ?? 0).toInt(),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    int? points,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      points: points ?? this.points,
    );
  }
}
