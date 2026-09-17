import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/ui_kit.dart';
import '../theme/app_theme.dart';
import 'admin_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // ✅ Admin login success
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SoftScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ Logo / Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 56,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 32),

              // ✅ Title
              Text(
                'Admin Login',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.ink,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your admin credentials to access the dashboard.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // ✅ Email Field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkLine : AppColors.line,
                  ),
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'admin@example.com',
                    prefixIcon: Icon(Icons.email_rounded),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.ink,
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Password Field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkLine : AppColors.line,
                  ),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.ink,
                  ),
                  onSubmitted: (_) => _login(),
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login as Admin',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),

              // ✅ Back to Home
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text('⬅ Back to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
