import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Represent phone auth verification complete.
const int kVComplete = 0;
// Represent phone auth verification failed.
const int kVFailed = 1;
// Represent phone auth verification code sent to the device.
const int kVCodeSent = 2;
// Entered phone number not valid
const int kNotValidPhoneNo = 3;
// Initial state
const int kInitialVerifyPhone = 4;

bool isValidPhoneNumber(String phoneNo) {
  final RegExp _matcher = RegExp(r'(^\+[1-9]\d{1,14}$)');
  if (phoneNo == null || phoneNo.isEmpty || !_matcher.hasMatch(phoneNo)) {
    return false;
  } else {
    return true;
  }
}

void logger(String msg) => debugPrint('AUTH: ====== $msg ======');

class AuthProvider {
  static final AuthProvider _instance = AuthProvider._internal();

  factory AuthProvider() {
    return _instance;
  }

  AuthProvider._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  StreamController<int> verifyStream = StreamController.broadcast();
  String verID = '';

  void dispose() {
    verifyStream?.close();
  }

  User get firebaseUser => _firebaseAuth.currentUser;

  bool isUserSigned() => _firebaseAuth.currentUser != null;

  Future<void> signOut() => _firebaseAuth.signOut();

  Future<void> verifyPhoneNumber(String phoneNo) async {
    // first check if the user entered a valid phone number
    bool isValidPhone = isValidPhoneNumber(phoneNo);

    // if not method yield a not valid phone.
    if (!isValidPhone) {
      verifyStream.add(kNotValidPhoneNo);
      //verifyStream.close();
    } else {
      // In case phone verification completed required
      final phoneVerificationCompleted = (AuthCredential authCredential) async {
        bool authResult = await authWithCredential(authCredential);

        if (authResult) {
          verifyStream.add(kVComplete);
        } else {
          verifyStream.add(kVFailed);
        }
        //verifyStream.close();
      };

      // In case phone verification failed
      final phoneVerificationFailed = (FirebaseAuthException exception) {
        logger('Auth failed with exception \n ${exception.message}');
        verifyStream.add(kVFailed);
        //verifyStream.close();
      };

      // When OTP sent to the user device
      final otpSent = (String verId, [int forceResent]) {
        this.verID = verId;
        verifyStream.add(kVCodeSent);
      };

      // When the timeout reached without receiving OTP
      final phoneCodeAutoRetrievalTimeout = (String verId) {
        this.verID = verId;
        verifyStream.close();
      };

      // Calling verifyPhoneNumber
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNo,
          timeout: const Duration(seconds: 1),
          verificationCompleted: phoneVerificationCompleted,
          verificationFailed: phoneVerificationFailed,
          codeSent: otpSent,
          codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout);
    }
  }

  Future<bool> authByPhoneNumber(String otp) async {
    // Create auth credential
    AuthCredential authCredential =
        PhoneAuthProvider.credential(verificationId: verID, smsCode: otp);

    bool result = await authWithCredential(authCredential);
    return result;
  }

  Future<bool> authWithCredential(AuthCredential credential) async {
    try {
      UserCredential result =
          await _firebaseAuth.signInWithCredential(credential);
      if (result.user != null) {
        return true;
      } else {
        logger('Auth with credential failed.');
        return false;
      }
    } catch (e) {
      logger('Auth with credential failed with error\n$e');
      return false;
    }
  }
}
