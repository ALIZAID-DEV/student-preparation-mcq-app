import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SoftScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool showPattern;

  const SoftScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          if (showPattern)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.seafoam.withValues(alpha: 0.9),
                        AppColors.mist,
                        const Color(0xFFFFF8F2).withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          body,
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: text.labelLarge?.copyWith(
            color: AppColors.accent,
            fontSize: 12,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: text.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: text.bodyMedium),
        ],
      ],
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;
  final int index;

  const CategoryTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.tint,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: tint, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.ink),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectTile extends StatelessWidget {
  final String title;
  final String caption;
  final int index;
  final VoidCallback onTap;

  const SubjectTile({
    super.key,
    required this.title,
    required this.caption,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 14),
          child: child,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.seafoam,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${index + 1}'.padLeft(2, '0'),
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(caption,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool selected;
  final bool correct;
  final bool showFeedback;
  final bool isSelectedWrong;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.label,
    required this.text,
    required this.selected,
    this.correct = false,
    this.showFeedback = false,
    this.isSelectedWrong = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrectTile = showFeedback && correct;
    final isWrongTile = showFeedback && isSelectedWrong;
    final tint = isCorrectTile
        ? AppColors.success
        : isWrongTile
            ? AppColors.danger
            : selected
                ? AppColors.ink
                : AppColors.mist;

    final bgColor = isCorrectTile
        ? AppColors.successSoft
        : isWrongTile
            ? AppColors.dangerSoft
            : selected
                ? AppColors.seafoam
                : Colors.white.withValues(alpha: 0.96);

    final borderColor = isCorrectTile
        ? AppColors.success
        : isWrongTile
            ? AppColors.danger
            : selected
                ? AppColors.ink
                : AppColors.line;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: selected || showFeedback ? 1.8 : 1.2,
        ),
        boxShadow: selected || showFeedback
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isCorrectTile || isWrongTile || selected
                          ? Colors.white
                          : AppColors.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: selected || showFeedback
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: AppColors.ink,
                        ),
                  ),
                ),
                if (showFeedback && isCorrectTile)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 22),
                if (showFeedback && isWrongTile)
                  const Icon(Icons.cancel_rounded,
                      color: AppColors.danger, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101828).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Ad',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sponsored placement',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ready for AdMob or partner promotions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.ads_click_rounded, color: Colors.white),
        ],
      ),
    );
  }
}

class QuizProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const QuizProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Question $current of $total',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.ink,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: AppColors.line,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
