import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../profile_setup.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _input = ''; // Single input for email or phone
  String _password = '';
  String _verificationId = '';
  String _smsCode = '';
  bool isPhone = false; // Flag to track whether the input is a phone number
  bool isCodeSent = false;

  GlobalKey<FormState> get formKey => _formKey;

  // Login method
  Future<void> login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_isPhoneNumber(_input)) {
        isPhone = true;
        // Handle phone sign-in
        if (isCodeSent) {
          await _signInWithPhoneOTP(context);
        } else {
          await _sendOTP(context);
        }
      } else {
        // Handle email/password sign-in
        try {
          await _auth.signInWithEmailAndPassword(email: _input, password: _password);
          Navigator.pushReplacementNamed(context, '/home');
        } catch (e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Login failed. Please try again.'),
          ));
        }
      }
    }
  }
// Method to handle the sign-up process
  Future<void> signUp(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (_isPhoneNumber(input)) {
        isPhone = true;
        if (isCodeSent) {
          // Handle OTP verification and sign-up for phone
          await _signUpWithPhoneOTP(context);
        } else {
          // Send OTP for phone number
          await _sendOTP(context);
        }
      } else {
        isPhone = false;
        try {
          // Handle email/password sign-up
          await _auth.createUserWithEmailAndPassword(
            email: input,
            password: password,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileSetupPage()),
          );
        } catch (e) {
          print(e);
          String errorMessage = 'Sign up failed. Please try again.';
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'email-already-in-use':
                errorMessage = 'This email is already in use. Please use a different email.';
                break;
              case 'invalid-email':
                errorMessage = 'The email address is not valid.';
                break;
              case 'weak-password':
                errorMessage = 'The password is too weak. Please choose a stronger password.';
                break;
              default:
                errorMessage = e.message ?? errorMessage;
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
        }
      }
    }
  }



  // Send OTP for Phone Number
  Future<void> _sendOTP(BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _input,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        Navigator.pushReplacementNamed(context, '/home');
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Phone verification failed: ${e.message}'),
        ));
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        isCodeSent = true; // Move to OTP entry step
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Method to sign up with OTP verification for phone numbers
  Future<void> _signUpWithPhoneOTP(BuildContext context) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );
    try {
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('OTP verification failed. Please try again.'),
      ));
    }
  }


  // Verify the OTP for Phone
  Future<void> _signInWithPhoneOTP(BuildContext context) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _smsCode,
    );
    try {
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('OTP verification failed. Please try again.'),
      ));
    }
  }



  // Sign in with Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // If the sign-in is successful, navigate to the homepage
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed. Please try again.')),
      );
    }
  }

  // Sign up with Google (Same as signInWithGoogle in this example)
  Future<void> signUpWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-up
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // If the sign-up is successful, navigate to the homepage
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-up failed. Please try again.')),
      );
    }
  }

  // Facebook Sign-In

  // Apple Sign-In
  Future<UserCredential?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
      final OAuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Forgot Password
  Future<void> forgotPassword(BuildContext context) async {
    if (_isPhoneNumber(_input)) {
      // If input is a phone number, we can't reset the password
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset is only available for email sign-in.')),
      );
    } else if (_input.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: _input);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sending password reset email.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
    }
  }

  // Check if the input is an email or phone number
  bool _isPhoneNumber(String input) {
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,}$'); // Simplistic check for a phone number
    return phoneRegExp.hasMatch(input);
  }

  // Getter methods for form fields
  String get input => _input;
  set input(String value) => _input = value;

  String get password => _password;
  set password(String value) => _password = value;

  String get smsCode => _smsCode;
  set smsCode(String value) => _smsCode = value;
}

