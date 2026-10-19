import 'package:flutter/material.dart';
import 'Services/Auth_services.dart';
import 'log_in.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _authService.formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _inputController,
                  decoration: const InputDecoration(labelText: 'Email or Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or phone number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _authService.input = value;
                  },
                ),
                if (!_authService.isPhone || !_authService.isCodeSent)
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (!_authService.isPhone && (value == null || value.isEmpty)) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _authService.password = value;
                    },
                  ),
                if (_authService.isPhone && _authService.isCodeSent)
                  TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(labelText: 'Enter OTP'),
                    onChanged: (value) {
                      _authService.smsCode = value;
                    },
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _authService.signUp(context),
                  child: Text(_authService.isPhone && !_authService.isCodeSent ? 'Send OTP' : 'Sign Up'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _authService.signUpWithGoogle(context),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign up with Google'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _authService.signInWithApple(),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign up with Apple'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text('Already have an account? Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
