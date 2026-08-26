import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleepy_driver/auth/models/user.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:sleepy_driver/auth/services/auth_service.dart';

class AuthServiceImpl implements AuthServiceInterface {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges(); 

  // sign in with phone number and OTP
  // sends OTP
 Future<String> sendOtp(String phoneNumber) async {
    final Completer<String> completer = Completer();

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      verificationCompleted:
          (PhoneAuthCredential credential) async {
        await firebaseAuth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e.message ?? 'Verification failed');
      },

      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return completer.future;
  }

  // verifies OTP 
  Future<UserModel> verifyOtp(String verificationId, String otp, String? name) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if (firebaseUser == null ){ throw Exception('Verification failed');}
    final userRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists)
    {
      final user = UserModel(
        userId: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        name: name?.trim().isNotEmpty == true ? name!.trim() : 'New User'
      );

      await userRef.set(user.toMap());
      return user;
    }

     return UserModel.fromMap(
    userDoc.data()!,
  );
  }
  
  String formatPhone1(String phone) {
  if (phone.startsWith('0')) {
    return phone.replaceFirst('0', '+94');
  }
  return phone;
  }
  
  Future<bool> phoneExists(String phone) async {
  String formatPhone = phone.trim();
  log('Phone number passed: $phone');
  log('Formatted phone: $formatPhone');
  final result = await FirebaseFunctions.instance.httpsCallable('checkIfPhoneNumberIsRegistered')
      .call({'phone': phone.trim()});
  log('Phone number passed: $formatPhone');
  return result.data['exists'] == true;
}

  // log out
  Future<void> logOut() async {
    await firebaseAuth.signOut();
  }

   // delete account
  Future<void> deleteUserAccount() async {
  try 
  {
  final user = firebaseAuth.currentUser;
  if (user != null)
  {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete(); // deleting from the firestore db
    await user.delete();
  }

  } on FirebaseAuthException catch (e) {
     log('$e');
     if (e.code == 'requires-recent-login')
     {
      reauthenticateAndDelete();
      throw Exception('Please re-authenticate before deleting your account.');
     }

  }
}

  Future<void> reauthenticateAndDelete() async {
  try {
    final providerData = firebaseAuth.currentUser?.providerData.first;

    if (AppleAuthProvider().providerId == providerData!.providerId) {
      await firebaseAuth.currentUser!
          .reauthenticateWithProvider(AppleAuthProvider());
    } else if (GoogleAuthProvider().providerId == providerData.providerId) {
      await firebaseAuth.currentUser!
          .reauthenticateWithProvider(GoogleAuthProvider());
    }

    await firebaseAuth.currentUser?.delete();
  } catch (e) {
    // Handle exceptions
  }
}

// checking if user is logged in
User? getCurrentUser() {
  return firebaseAuth.currentUser;
}
}