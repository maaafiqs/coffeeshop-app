class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role; // 'customer' or 'admin'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'customer',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'customer',
    );
  }
}
