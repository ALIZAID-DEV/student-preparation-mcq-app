import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

class LearningScreen extends StatelessWidget {
  final String categoryId;
  final String subCategoryId;
  final String title;

  const LearningScreen({
    super.key,
    required this.categoryId,
    required this.subCategoryId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SoftScaffold(
      appBar: AppBar(title: Text('Learn: $title')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              eyebrow: 'Study Material',
              title: 'Key Concepts',
              subtitle:
                  'Read through the topics below, then practice with quizzes.',
            ),
            const SizedBox(height: 22),
            _buildConceptCard(
              context,
              '1. Introduction to Topic',
              'This section covers the fundamental concepts you need to understand before attempting the MCQs. Start with the basics and build your foundation.',
            ),
            _buildConceptCard(
              context,
              '2. Important Formulas & Rules',
              'Memorize these core formulas. They will help you solve questions quickly and accurately during the practice quiz.',
            ),
            _buildConceptCard(
              context,
              '3. Common Pitfalls & Tips',
              'Avoid common mistakes by understanding these exam-style traps. Practice these tips in the quiz section to master the subject.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Subjects'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConceptCard(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      // ✅ FIX: Dark mode color apply kiya
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkCard : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.ink,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
