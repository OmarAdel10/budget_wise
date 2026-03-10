// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String id;
  final String userName;
  final String email;

  const UserModel({
    required this.id,
    required this.userName,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'userName': userName, 'email': email};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      userName: map['userName'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
