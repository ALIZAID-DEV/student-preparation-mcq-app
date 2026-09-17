import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/ui_kit.dart';
import 'quiz_screen.dart';
import 'learning_screen.dart';

class SubCategoryScreen extends StatefulWidget {
  final Category category;

  const SubCategoryScreen({super.key, required this.category});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  Map<String, dynamic> _progressData = {};
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await StorageService.loadProgress();
    final name = await StorageService.getUserName();
    if (!mounted) return;
    setState(() {
      _progressData = data;
      _userName = name;
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  // 🔥 Check if user has name before quiz
  Future<void> _checkUserAndStartQuiz(
      BuildContext context, String subCatId, String title) async {
    final name = await StorageService.getUserName();
    if (name.isEmpty || name == 'Anonymous') {
      final TextEditingController nameController = TextEditingController();
      final isDark = Theme.of(context).brightness == Brightness.dark;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.person_rounded, color: AppColors.accent),
                SizedBox(width: 8),
                Text('Enter Your Name'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please enter your name to start the quiz.'),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your name...',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.ink,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) async {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('userName', name);
                      if (!mounted) return;
                      Navigator.pop(context);
                      _startQuiz(context, subCatId, title);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('⚠️ Please enter your name.')),
                    );
                    return;
                  }
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('userName', name);
                  if (!mounted) return;
                  Navigator.pop(context);
                  _startQuiz(context, subCatId, title);
                },
                child: const Text('Start Quiz'),
              ),
            ],
          );
        },
      );
    } else {
      _startQuiz(context, subCatId, title);
    }
  }

  void _startQuiz(BuildContext context, String subCatId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          categoryId: widget.category.categoryId,
          subCategoryId: subCatId,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SoftScaffold(
      appBar: AppBar(title: Text(widget.category.categoryTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
              children: [
                const SectionHeader(
                  eyebrow: 'Subjects',
                  title: 'Pick a section',
                  subtitle: 'Study the material and test your knowledge.',
                ),
                const SizedBox(height: 22),
                ...List.generate(widget.category.subCategories.length, (index) {
                  final subCat = widget.category.subCategories[index];

                  final sectionData = _progressData[subCat.id];
                  final int totalAttempted = sectionData != null
                      ? (sectionData['totalAttempted'] ?? 0)
                      : 0;
                  final int totalCorrect = sectionData != null
                      ? (sectionData['totalCorrect'] ?? 0)
                      : 0;
                  final double progressPercent = totalAttempted == 0
                      ? 0.0
                      : (totalCorrect / totalAttempted);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 0,
                      color: isDark
                          ? AppColors.darkCard
                          : Colors.white.withValues(alpha: 0.95),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                            color:
                                isDark ? AppColors.darkLine : AppColors.line),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      subCat.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                ),
                                if (totalAttempted > 0) ...[
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: CircularProgressIndicator(
                                              value: progressPercent,
                                              strokeWidth: 4,
                                              backgroundColor: isDark
                                                  ? AppColors.darkLine
                                                  : AppColors.line,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                progressPercent >= 0.7
                                                    ? AppColors.success
                                                    : AppColors.accent,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            '${(progressPercent * 100).toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (totalAttempted > 0)
                              Text(
                                'Attempted: $totalAttempted • Correct: $totalCorrect',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LearningScreen(
                                            categoryId:
                                                widget.category.categoryId,
                                            subCategoryId: subCat.id,
                                            title: subCat.title,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.menu_book_rounded),
                                    label: const Text('Learn'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.seafoam,
                                      foregroundColor: AppColors.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _checkUserAndStartQuiz(
                                        context,
                                        subCat.id,
                                        subCat.title,
                                      );
                                    },
                                    icon: const Icon(Icons.quiz_rounded),
                                    label: const Text('Practice Quiz'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
