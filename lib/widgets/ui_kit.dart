import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/app_theme.dart';
import '../services/ad_service.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        isDark
                            ? AppColors.darkCard.withValues(alpha: 0.2)
                            : AppColors.seafoam.withValues(alpha: 0.9),
                        isDark ? AppColors.darkBg : AppColors.mist,
                        isDark
                            ? AppColors.darkBg.withValues(alpha: 0.55)
                            : const Color(0xFFFFF8F2).withValues(alpha: 0.55),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: isDark
                  ? AppColors.darkCard
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: isDark ? AppColors.darkLine : AppColors.line),
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

// ❌ SubjectTile yahan se DELETE kar diya gaya hai

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorrectTile = showFeedback && correct;
    final isWrongTile = showFeedback && isSelectedWrong;

    final tint = isCorrectTile
        ? AppColors.success
        : isWrongTile
            ? AppColors.danger
            : selected
                ? (isDark ? AppColors.accent : AppColors.ink)
                : (isDark ? const Color(0xFF2C2C2C) : AppColors.mist);

    final bgColor = isCorrectTile
        ? (isDark ? AppColors.darkSuccessSoft : AppColors.successSoft)
        : isWrongTile
            ? (isDark ? AppColors.darkDangerSoft : AppColors.dangerSoft)
            : selected
                ? (isDark
                    ? AppColors.darkCard.withValues(alpha: 0.9)
                    : AppColors.seafoam)
                : (isDark
                    ? AppColors.darkCard
                    : Colors.white.withValues(alpha: 0.96));

    final borderColor = isCorrectTile
        ? AppColors.success
        : isWrongTile
            ? AppColors.danger
            : selected
                ? (isDark ? Colors.white : AppColors.ink)
                : (isDark ? AppColors.darkLine : AppColors.line);

    final labelTextColor = isCorrectTile || isWrongTile || selected
        ? Colors.white
        : (isDark ? Colors.white : AppColors.ink);

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
                      color: labelTextColor,
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
                          color: isDark ? Colors.white : AppColors.ink,
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

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (kIsWeb) return;
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
            });
          }
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (kIsWeb) {
      return Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.mist,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
        ),
        child: Center(
          child: Text(
            '📢 Sponsor',
            style: TextStyle(
              color: isDark ? AppColors.darkMuted : AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (_bannerAd == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.mist,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AdWidget(ad: _bannerAd!),
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
