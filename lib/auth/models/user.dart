class UserModel
{
  String userId;
  String name;
  String phoneNumber;

  UserModel({required this.userId, required this.name, required this.phoneNumber});

   Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

// mapping to jSON for firebase to recognize
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}