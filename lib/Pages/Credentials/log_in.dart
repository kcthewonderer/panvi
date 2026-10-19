import 'package:flutter/material.dart';
import 'Services/Auth_services.dart';
import 'sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _authService.formKey,
          child: SingleChildScrollView( // To prevent overflow errors
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
                if (!_authService.isPhone || !_authService.isCodeSent) // Show password field only for email login or before OTP is sent
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
                if (_authService.isPhone && _authService.isCodeSent) // Show OTP field only when code is sent for phone login
                  TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(labelText: 'Enter OTP'),
                    onChanged: (value) {
                      _authService.smsCode = value;
                    },
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _authService.login(context),
                  child: Text(_authService.isPhone && !_authService.isCodeSent ? 'Send OTP' : 'Login'),
                ),
                if (!_authService.isPhone) // Show forgot password only for email login
                  TextButton(
                    onPressed: () => _authService.forgotPassword(context),
                    child: const Text('Forgot Password?'),
                  ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _authService.signInWithGoogle(context),
                  icon:  Image.asset(
                    'Assets/Google-2.png', // Ensure the Google icon is in your assets
                    height: 20,
                  ),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _authService.signInWithApple(),
                  icon: const Icon(
                    Icons.apple,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: const Text('Sign in with Apple'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: const Text('Don\'t have an account? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
