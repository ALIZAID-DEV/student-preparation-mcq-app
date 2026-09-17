import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import 'home_screen.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfNameExists();
  }

  Future<void> _checkIfNameExists() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    if (name != null && name.isNotEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name to continue.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
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
      showPattern: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  Icons.school_rounded,
                  size: 56,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Mickey Prep! 🚀',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.ink,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your name to continue and track your progress.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkLine : AppColors.line,
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name...',
                    prefixIcon: Icon(Icons.person_rounded),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveName(),
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveName,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                        'Continue ➜',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                '💡 Your name will be saved locally.\nAll your quiz attempts will be saved with your name.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
