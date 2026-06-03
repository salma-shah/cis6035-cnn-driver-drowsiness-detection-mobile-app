import 'package:sleepy_driver/auth/models/user.dart';
import 'package:sleepy_driver/user_profile/services/user_profile_service.dart';

class UserProfileRepo
{
   final UserProfileService authService = UserProfileService();

   Future<UserModel?> getUserProfile() async
   {
    return await authService.getCurrentUser();
   }

   // update user details
   Future<void> updateUserFields(Map<String,dynamic> fields) async
    {
    return await authService.updateUserFields(fields);   }
}