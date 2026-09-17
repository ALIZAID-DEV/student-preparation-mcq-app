import 'package:flutter/material.dart';
import '../models/wrong_answer.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import 'review_screen.dart';

class ResultScreen extends StatelessWidget {
  final String quizTitle;
  final int score;
  final int total;
  final int wrong;
  final List<WrongAnswer> wrongAnswers;

  const ResultScreen({
    super.key,
    required this.quizTitle,
    required this.score,
    required this.total,
    required this.wrong,
    required this.wrongAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = total == 0 ? 0.0 : (score / total) * 100;

    late final String msg;
    late final IconData icon;
    late final Color color;

    if (pct >= 80) {
      msg = 'Excellent! Keep practicing.';
      icon = Icons.emoji_events_rounded;
      color = AppColors.accent;
    } else if (pct >= 50) {
      msg = 'Good! You passed this practice.';
      icon = Icons.thumb_up_alt_rounded;
      color = AppColors.success;
    } else {
      msg = 'Keep practicing. Review your weak areas.';
      icon = Icons.psychology_alt_rounded;
      color = const Color(0xFFC17B2B);
    }

    return SoftScaffold(
      appBar: AppBar(
        title: const Text('Result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.86, end: 1),
                duration: const Duration(milliseconds: 520),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
                  // ✅ FIX: Dark mode color apply kiya
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard
                        : Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: isDark ? AppColors.darkLine : AppColors.line),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 40, color: color),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        quizTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$score / $total',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: color,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                // ✅ FIX: Dark mode color apply kiya
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark ? AppColors.darkLine : AppColors.line),
                ),
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Correct',
                      value: '$score',
                      color: AppColors.success,
                    ),
                    const Divider(height: 22, color: AppColors.line),
                    _StatRow(
                      label: 'Wrong',
                      value: '$wrong',
                      color: AppColors.danger,
                    ),
                    const Divider(height: 22, color: AppColors.line),
                    _StatRow(
                      label: 'Total',
                      value: '$total',
                      color: AppColors.ink,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (wrongAnswers.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewScreen(
                            title: 'Wrong Answers Review',
                            wrongAnswers: wrongAnswers,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('Review Wrong Answers'),
                  ),
                ),
              if (wrongAnswers.isNotEmpty) const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
}
