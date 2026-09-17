import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../services/data_loader_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/ui_kit.dart';
import '../constants/category_constants.dart';
import 'subcategory_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;
  int _totalQuizzes = 0;
  String _currentUserName = '';

  // 🔥 Admin Login Dialog ke liye
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  bool _isAdminLoading = false;
  bool _obscureAdminPassword = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadStats();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await StorageService.getUserName();
    if (mounted) {
      setState(() => _currentUserName = name);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DataLoaderService.loadCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
        _error = categories.isEmpty ? 'No categories found.' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load categories.';
      });
    }
  }

  Future<void> _loadStats() async {
    final data = await StorageService.loadProgress();
    if (!mounted) return;
    setState(() {
      _totalQuizzes = data['totalQuizCompleted'] ?? 0;
    });
  }

  // 🔥 User Name Dialog (Force name before any quiz)
  Future<void> _showUserNameDialog({required VoidCallback onContinue}) async {
    final TextEditingController nameController = TextEditingController();
    nameController.text = _currentUserName;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.person_rounded, color: AppColors.accent),
              const SizedBox(width: 8),
              const Text('Enter Your Name'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your name to continue with quizzes.'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter your name...',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkLine : AppColors.line,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.ink,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  _saveUserName(
                      nameController.text.trim(), context, onContinue);
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _saveUserName(nameController.text.trim(), context, onContinue);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUserName(
      String name, BuildContext context, VoidCallback onContinue) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter your name to continue.')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    if (!mounted) return;
    Navigator.pop(context);
    setState(() => _currentUserName = name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Welcome, $name!')),
    );
    onContinue();
  }

  // 🔥 Check if user has name before proceeding
  Future<void> _checkUserAndProceed(VoidCallback onProceed) async {
    if (_currentUserName.isEmpty || _currentUserName == 'Anonymous') {
      await _showUserNameDialog(onContinue: onProceed);
    } else {
      onProceed();
    }
  }

  // 🔥 Admin Login Dialog
  Future<void> _showAdminLoginDialog() async {
    _adminEmailController.clear();
    _adminPasswordController.clear();
    setState(() {
      _isAdminLoading = false;
      _obscureAdminPassword = true;
    });

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Text('Admin Login'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter admin credentials to access dashboard.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _adminEmailController,
                    decoration: InputDecoration(
                      hintText: 'admin@example.com',
                      prefixIcon: const Icon(Icons.email_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkLine : AppColors.line,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.accent),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.ink,
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _adminPasswordController,
                    obscureText: _obscureAdminPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureAdminPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            _obscureAdminPassword = !_obscureAdminPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkLine : AppColors.line,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.accent),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.ink,
                    ),
                    onSubmitted: (_) => _adminLogin(context, setDialogState),
                  ),
                  if (_isAdminLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isAdminLoading
                      ? null
                      : () => _adminLogin(context, setDialogState),
                  child: const Text('Login'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _adminLogin(
      BuildContext context, StateSetter setDialogState) async {
    final email = _adminEmailController.text.trim();
    final password = _adminPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setDialogState(() => _isAdminLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        if (!mounted) return;
        Navigator.pop(context);
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
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setDialogState(() => _isAdminLoading = false);
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    const number = '923162196306';
    const message =
        'Hi! I have a suggestion about the Student Preparation App.';
    final url = 'https://wa.me/$number?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Could not launch WhatsApp. Please check if it is installed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDark;

        return SoftScaffold(
          appBar: AppBar(
            title: const Text('Choose your exam track'),
            actions: [
              IconButton(
                icon: Icon(themeProvider.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded),
                onPressed: () => themeProvider.toggleTheme(),
              ),
              IconButton(
                icon: const Icon(Icons.person_rounded),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _launchWhatsApp,
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.chat_bubble_rounded),
            label: const Text('Suggest / Review'),
          ),
          body: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorState(
                        message: _error!,
                        onRetry: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadCategories();
                        })
                    : Column(
                        children: [
                          // ✅ User Info + Admin Login Banner
                          Container(
                            margin: const EdgeInsets.fromLTRB(22, 12, 22, 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        AppColors.darkCard,
                                        AppColors.darkCard
                                            .withValues(alpha: 0.8)
                                      ]
                                    : [AppColors.seafoam, Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkLine
                                    : AppColors.line,
                              ),
                            ),
                            child: Row(
                              children: [
                                // ✅ User Info (Click to change name)
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      _showUserNameDialog(
                                        onContinue: () {
                                          _loadUserName();
                                        },
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _currentUserName.isNotEmpty &&
                                                _currentUserName != 'Anonymous'
                                            ? AppColors.successSoft
                                            : AppColors.accentSoft,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _currentUserName.isNotEmpty &&
                                                  _currentUserName !=
                                                      'Anonymous'
                                              ? AppColors.success
                                              : AppColors.accent,
                                          width: _currentUserName.isNotEmpty &&
                                                  _currentUserName !=
                                                      'Anonymous'
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_rounded,
                                            color:
                                                _currentUserName.isNotEmpty &&
                                                        _currentUserName !=
                                                            'Anonymous'
                                                    ? AppColors.success
                                                    : AppColors.accent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _currentUserName.isNotEmpty &&
                                                    _currentUserName !=
                                                        'Anonymous'
                                                ? '👤 $_currentUserName'
                                                : '⚠️ Set Your Name',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  _currentUserName.isNotEmpty &&
                                                          _currentUserName !=
                                                              'Anonymous'
                                                      ? AppColors.success
                                                      : AppColors.accent,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.edit_rounded,
                                            color:
                                                _currentUserName.isNotEmpty &&
                                                        _currentUserName !=
                                                            'Anonymous'
                                                    ? AppColors.success
                                                    : AppColors.accent,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // ✅ Admin Login Button
                                Expanded(
                                  child: InkWell(
                                    onTap: _showAdminLoginDialog,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentSoft,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.accent,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.admin_panel_settings_rounded,
                                            color: AppColors.accent,
                                            size: 20,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            '🔐 Admin',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ✅ Main Content
                          Expanded(
                            child: CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(22, 8, 22, 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 160),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.ink,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'M I C K E Y preparations',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                      color: const Color(
                                                          0xFF00FFFF),
                                                      shadows: [
                                                        Shadow(
                                                          color: const Color(
                                                                  0xFF00FFFF)
                                                              .withValues(
                                                                  alpha: 0.6),
                                                          blurRadius: 10,
                                                          offset: const Offset(
                                                              0, 0),
                                                        ),
                                                        Shadow(
                                                          color: const Color(
                                                                  0xFF00FFFF)
                                                              .withValues(
                                                                  alpha: 0.8),
                                                          blurRadius: 20,
                                                          offset: const Offset(
                                                              0, 0),
                                                        ),
                                                        Shadow(
                                                          color: const Color(
                                                                  0xFF00FFFF)
                                                              .withValues(
                                                                  alpha: 1.0),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              0, 0),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 160),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: AppColors.line),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    '${_categories.length} exams | $_totalQuizzes quizzes',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge
                                                        ?.copyWith(
                                                            color: AppColors
                                                                .muted),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 28),
                                        const SectionHeader(
                                            eyebrow: 'Practice smarter',
                                            title: 'Choose your exam track',
                                            subtitle:
                                                '100+ practice MCQs in every section — pick a path and start.'),
                                        const SizedBox(height: 22),
                                      ],
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.fromLTRB(22, 0, 22, 28),
                                  sliver: SliverList.separated(
                                    itemCount: _categories.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 14),
                                    itemBuilder: (context, index) {
                                      final category = _categories[index];
                                      return CategoryTile(
                                          index: index,
                                          title: category.categoryTitle,
                                          description: category.description,
                                          icon: CategoryConstants.getIconData(
                                              category.icon),
                                          tint: CategoryConstants.getLightTint(
                                              index),
                                          onTap: () {
                                            // ✅ FORCE NAME BEFORE QUIZ
                                            _checkUserAndProceed(() {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      SubCategoryScreen(
                                                    category: category,
                                                  ),
                                                ),
                                              );
                                            });
                                          });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 42, color: AppColors.muted),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry'))
            ])));
  }
}
