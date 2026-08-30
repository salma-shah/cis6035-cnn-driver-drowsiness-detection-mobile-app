import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleepy_driver/auth/models/user.dart';

abstract class UserProfileServiceInterface {
  User? get currentUser;

  Future<UserModel?> getCurrentUser();

  Future<void> updateUserFields(
    Map<String, dynamic> fields,
  );
}