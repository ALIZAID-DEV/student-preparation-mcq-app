import 'package:flutter/material.dart';
import '../models/wrong_answer.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

class ReviewScreen extends StatelessWidget {
  final String title;
  final List<WrongAnswer> wrongAnswers;

  const ReviewScreen({
    super.key,
    required this.title,
    required this.wrongAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SoftScaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: wrongAnswers.isEmpty
          ? const Center(
              child: Text(
                'No wrong answers to review.',
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
              itemCount: wrongAnswers.length,
              itemBuilder: (context, index) {
                final w = wrongAnswers[index];
                final q = w.question;

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 14,
                  ),
                  padding: const EdgeInsets.all(18),
                  // ✅ FIX: Dark mode color apply kiya
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard
                        : Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkLine : AppColors.line,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUESTION ${index + 1}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.accent,
                              letterSpacing: 1.1,
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        q.question,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(
                        q.shuffledOptions.length,
                        (oi) {
                          final isCorrect = oi == q.shuffledCorrectIndex;
                          final isWrongPick =
                              oi == w.selectedIndex && !isCorrect;

                          Color bg = isDark
                              ? AppColors.darkCard.withValues(alpha: 0.5)
                              : AppColors.mist;
                          Color border =
                              isDark ? AppColors.darkLine : AppColors.line;
                          Color fg = isDark ? Colors.white : AppColors.ink;

                          if (isCorrect) {
                            bg = AppColors.successSoft;
                            border = AppColors.success.withValues(alpha: 0.35);
                            fg = AppColors.success;
                          } else if (isWrongPick) {
                            bg = AppColors.dangerSoft;
                            border = AppColors.danger.withValues(alpha: 0.35);
                            fg = AppColors.danger;
                          }

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                              bottom: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              border: Border.all(
                                color: border,
                              ),
                            ),
                            child: Text(
                              '${String.fromCharCode(65 + oi)}. '
                              '${q.shuffledOptions[oi]}',
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.seafoam,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explanation',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppColors.ink,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              q.explanation.trim().isEmpty
                                  ? 'No explanation added.'
                                  : q.explanation.trim(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
