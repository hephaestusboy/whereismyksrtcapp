import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class SignInWidget extends StatefulWidget {
  final ApiService? apiService;
  const SignInWidget({super.key, this.apiService});

  static String routeName = 'SignIn';
  static String routePath = '/sign-in';

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final _formKey = GlobalKey<FormState>();
  late final ApiService _apiService;
  bool _isLoading = false;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await _apiService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 12),
                const Text(
                  'Success!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have signed in successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    context.go('/popup'); // Redirect to popup.dart
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                     if (Navigator.of(context).canPop()) {
                        context.pop();
                    } else {
                        context.go('/');
                   }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your email';
                            } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                .hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Enter your password' : null,
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: _isLoading ? null : () => context.go('/create-acc'),
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
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
