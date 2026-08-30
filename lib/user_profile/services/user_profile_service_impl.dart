import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleepy_driver/auth/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleepy_driver/user_profile/services/user_profile_service.dart';

class UserProfileServiceImpl implements UserProfileServiceInterface {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => firebaseAuth.currentUser;

  // getting current user
 Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }

    // update name 
  Future<void> updateUserFields(Map<String, dynamic> fields) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null)
    {
      return null;
    }

    await FirebaseFirestore.instance
    .collection('users')
    .doc(currentUser.uid)
    .update(fields);
  }

}