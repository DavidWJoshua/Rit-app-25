class MyUser {
  String phoneNumber;
  String? role;

  MyUser({required this.phoneNumber, this.role});

  factory MyUser.fromMap(Map<String, dynamic> data) {
    return MyUser(
      phoneNumber: data['phonenumber'],
      role: data['role'],
    );
  }

  Map<String, dynamic> toMap() => {
    'phonenumber': phoneNumber,
    'role': role,
  };
}
