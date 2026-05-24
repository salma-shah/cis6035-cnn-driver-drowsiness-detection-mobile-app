import 'package:sleepy_driver/auth/models/user.dart';
import 'package:sleepy_driver/auth/services/auth_service.dart';

class AuthRepo {
  final AuthService authService = AuthService();

  Future<bool> phoneExists(String phone) async {
    return await authService.phoneExists(phone);
  }

  Future<String> sendOtp(String phoneNum, String verificationId) async {
    return await authService.sendOtp(phoneNum);
  }

  Future<UserModel> verifyOtp(String verificationId, String otp, String? name) async 
  {
    final firebaseUser =
        await authService.verifyOtp(verificationId, otp, name);
    return firebaseUser;
  }

  Future<void> deleteUserAccount() async
  {
    return await authService.deleteUserAccount();
  }

   Future<void> logOut() async
  {
    return await authService.logOut();
  }
}