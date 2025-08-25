import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram/features/Authentication/logics/auth_cubit.dart';
import 'package:instagram/features/Authentication/logics/auth_state.dart';
import 'package:instagram/features/Authentication/Presentation/forget_password_screen.dart';
import 'package:instagram/features/Authentication/Presentation/signup_screen.dart';
import 'package:instagram/features/Home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login'; // Fixed routeName
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginWithEmail() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  void _loginWithGoogle() {
    context.read<AuthCubit>().loginWithGoogle();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.black,
    Color foregroundColor = Colors.white,
    bool loading = false,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: icon != null ? FaIcon(icon, size: 20) : const SizedBox.shrink(),
        label: loading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              )
            : Text(label),
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        setState(() => _isLoading = state is AuthLoading);

        if (state is AuthLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(currentUserId: state.user.uid),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFEEF2F7),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value != null && value.contains("@")
                            ? null
                            : "Enter valid email",
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) => value != null && value.length >= 6
                            ? null
                            : "Minimum 6 characters",
                      ),
                      const SizedBox(height: 30),
                      _buildButton(
                        label: 'Login',
                        onPressed: _loginWithEmail,
                        loading: _isLoading,
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        label: 'Continue with Google',
                        onPressed: _loginWithGoogle,
                        loading: _isLoading,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        icon: FontAwesomeIcons.google,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text("Don't have an account? Sign up"),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text("Forgot Password?"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
