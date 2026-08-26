import 'package:sleepy_driver/auth/models/user.dart';
import 'package:sleepy_driver/user_profile/services/user_profile_service.dart';
import 'package:sleepy_driver/user_profile/services/user_profile_service_impl.dart';

class UserProfileRepo {
  final UserProfileServiceInterface userProfileService;

  UserProfileRepo({
    UserProfileServiceInterface? userProfileService,
  }) : userProfileService =
            userProfileService ?? UserProfileServiceImpl();

  Future<UserModel?> getUserProfile() async {
    return userProfileService.getCurrentUser();
  }

  Future<void> updateUserFields(
    Map<String, dynamic> fields,
  ) async {
    return userProfileService.updateUserFields(fields);
  }
}