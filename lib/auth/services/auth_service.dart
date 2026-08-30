import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleepy_driver/auth/models/user.dart';

abstract class AuthServiceInterface {
  User? get currentUser;

  Stream<User?> get authStateChanges;

  Future<String> sendOtp(
    String phoneNumber,
  );

  Future<UserModel> verifyOtp(
    String verificationId,
    String otp,
    String? name,
  );

  String formatPhone1(
    String phone,
  );

  Future<bool> phoneExists(
    String phone,
  );

  Future<void> logOut();

  Future<void> deleteUserAccount();

  Future<void> reauthenticateAndDelete();

  User? getCurrentUser();
}