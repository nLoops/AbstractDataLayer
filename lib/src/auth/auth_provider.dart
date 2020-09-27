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

void logAuth(String msg) => debugPrint('AUTH: ====== $msg ======');

class AuthProvider {
  static final AuthProvider _instance = AuthProvider._internal();

  factory AuthProvider() {
    return _instance;
  }

  AuthProvider._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String verID = '';

  void dispose() {}

  User get firebaseUser => _firebaseAuth.currentUser;

  bool isUserSigned() => _firebaseAuth.currentUser != null;

  Future<void> signOut() => _firebaseAuth.signOut();

  Stream<int> verifyPhoneNumber(String phoneNo) async* {
    StreamController<int> eventStream = StreamController();

    // first check if the user entered a valid phone number
    bool isValidPhone = isValidPhoneNumber(phoneNo);

    // if not method yield a not valid phone.
    if (!isValidPhone) {
      eventStream.add(kNotValidPhoneNo);
      eventStream.close();
    } else {
      // In case phone verification completed required
      final phoneVerificationCompleted = (AuthCredential authCredential) async {
        bool authResult = await authWithCredential(authCredential);

        if (authResult) {
          eventStream.add(kVComplete);
        } else {
          eventStream.add(kVFailed);
        }
        eventStream.close();
      };

      // In case phone verification failed
      final phoneVerificationFailed = (FirebaseAuthException exception) {
        logAuth('Auth failed with exception \n ${exception.message}');
        eventStream.add(kVFailed);
        eventStream.close();
      };

      // When OTP sent to the user device
      final otpSent = (String verId, [int forceResent]) {
        this.verID = verId;
        eventStream.add(kVCodeSent);
      };

      // When the timeout reached without receiving OTP
      final phoneCodeAutoRetrievalTimeout = (String verId) {
        this.verID = verId;
        eventStream.close();
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
    yield* eventStream.stream;
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
        logAuth('Auth with credential failed.');
        return false;
      }
    } catch (e) {
      logAuth('Auth with credential failed with error\n$e');
      return false;
    }
  }
}
