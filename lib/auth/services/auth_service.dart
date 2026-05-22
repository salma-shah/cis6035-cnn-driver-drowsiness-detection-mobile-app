import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleepy_driver/auth/models/user.dart';

class AuthService {
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

  // verifies OTP and signs in
  Future<UserModel?> verifyOtp(String verificationId, String otp) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
   final firebaseUser =
      userCredential.user;

  if (firebaseUser == null) {
    return null;
  }

  UserModel user = UserModel(
    userId: firebaseUser.uid,
    name: firebaseUser.displayName ?? '',
    email: firebaseUser.phoneNumber ?? '',
  );
  return user;
  }

  // log out
  Future<void> logOut() async {
    await firebaseAuth.signOut();
  }

  // update name 
  Future<void> updateName(String name) async {
    User? user = currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
    }
  }

  // update phone number
  // Future<void> updatePhoneNumber(String phoneNumber) async {
  //   User? user = currentUser;
  //   if (user != null) {
  //     await signInWithPhone(phoneNumber, (verificationId) async {
  //       // Handle OTP verification and update phone number
  //       // This is a placeholder for the actual OTP verification process
  //       // You would need to implement the logic to verify the OTP and update the phone number
  //     });
  //   }
  // }

  // delete account
  Future<void> deleteUserAccount() async {
  try {
  await FirebaseAuth.instance.currentUser!.delete();

  } on FirebaseAuthException catch (e) {
    //log.e(e);

    if (e.code == "requires-recent-login") {
      await _reauthenticateAndDelete();
    } else {
      // Handle other Firebase exceptions
    }
  } catch (e) {
   // log.e(e);

    // Handle general exception
  }
}

  Future<void> _reauthenticateAndDelete() async {
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
 

 // sign in with email ans password
 Future<UserModel?> signUp(String email, String password, String name) async {
   try {
     UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
       email: email,
       password: password,
     );
     final firebaseUser = userCredential.user;

     if (firebaseUser == null) {
       return null;
     }

     // updating firebase user name
     await firebaseUser.updateDisplayName(name);

     UserModel user = UserModel(
       userId: firebaseUser.uid,
       name: name,
       email: firebaseUser.email ?? '',
     );
     return user;
   } on FirebaseAuthException catch (e) {
     // Handle authentication errors
     throw Exception(e.message);
   }
 }

 // login
 Future<UserModel?> login({

    required String email,
    required String password,

  }) async {

    UserCredential userCredential =
        await firebaseAuth
            .signInWithEmailAndPassword(

      email: email,
      password: password,
    );
    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      return null;
    }

    UserModel user = UserModel(
      userId: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? ''
    );
    return user;
  }

  Future<void> logout() async {

    await firebaseAuth.signOut();
  }

}