import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  static String routeName = 'SignIn';
  static String routePath = 'sign-in';

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Mock authentication function (Replace with actual Firebase/Auth logic)
  Future<bool> _signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return email == "test@example.com" && password == "password123"; // Dummy auth logic
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    bool isAuthenticated = await _signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (isAuthenticated) {
      context.go('/dashboard'); // Navigate to dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter your email' : null,
                      ),
                      const SizedBox(height: 18),
                      _buildTextField(
                        label: 'Password',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: !_passwordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter your password' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Sign In'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          // Handle forgot password logic
                        },
                        child: const Text('Forgot Password?'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          context.push('/create-account'); // Navigate to create account page
                        },
                        child: const Text("Don't have an account? Create one"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}