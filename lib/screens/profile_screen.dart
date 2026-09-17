import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../services/storage_service.dart';
import '../widgets/ui_kit.dart';
import 'history_screen.dart';
import 'leaderboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _progressData = {};
  bool _isLoading = true;
  String _userName = '';
  int _totalCorrectAll = 0;
  int _totalWrongAll = 0;
  int _totalAttemptedAll = 0;
  int _totalQuizzes = 0;

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
      _totalCorrectAll = data['totalCorrectAll'] ?? 0;
      _totalWrongAll = data['totalWrongAll'] ?? 0;
      _totalAttemptedAll = data['totalAttemptedAll'] ?? 0;
      _totalQuizzes = data['totalQuizCompleted'] ?? 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pctAll = _totalAttemptedAll == 0
        ? 0
        : (_totalCorrectAll / _totalAttemptedAll * 100);

    return SoftScaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_rounded),
            onPressed: () {
              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ User Name Card with Total Stats
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkLine : AppColors.line,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: isDark
                                  ? AppColors.darkSuccessSoft
                                  : AppColors.accentSoft,
                              child: Icon(
                                Icons.person_rounded,
                                size: 32,
                                color: isDark ? Colors.white : AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkMuted
                                          : AppColors.muted,
                                    ),
                                  ),
                                  Text(
                                    _userName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark ? Colors.white : AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSuccessSoft
                                    : AppColors.successSoft,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.success),
                              ),
                              child: Text(
                                '$_totalQuizzes Quizzes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ✅ Overall Progress Bar
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Overall Progress',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkMuted
                                              : AppColors.muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${pctAll.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: pctAll >= 70
                                              ? AppColors.success
                                              : AppColors.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _totalAttemptedAll == 0
                                          ? 0
                                          : _totalCorrectAll /
                                              _totalAttemptedAll,
                                      minHeight: 8,
                                      backgroundColor: isDark
                                          ? AppColors.darkLine
                                          : AppColors.line,
                                      color: pctAll >= 70
                                          ? AppColors.success
                                          : AppColors.accent,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '✅ $_totalCorrectAll correct  ❌ $_totalWrongAll wrong  📝 $_totalAttemptedAll total',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkMuted
                                          : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionHeader(
                    eyebrow: 'Statistics',
                    title: 'Section-wise Performance',
                    subtitle: 'Track your MCQs progress across all sections.',
                  ),
                  const SizedBox(height: 22),
                  if (_progressData.isNotEmpty)
                    ..._progressData.keys.map((sectionId) {
                      if (sectionId == 'totalQuizCompleted' ||
                          sectionId == 'totalCorrectAll' ||
                          sectionId == 'totalWrongAll' ||
                          sectionId == 'totalAttemptedAll' ||
                          sectionId.startsWith('total')) {
                        return const SizedBox.shrink();
                      }

                      final data = _progressData[sectionId];
                      final correct = data['totalCorrect'] ?? 0;
                      final wrong = data['totalWrong'] ?? 0;
                      final total = data['totalAttempted'] ?? 0;
                      final title = data['title'] ?? 'Section';
                      if (total == 0) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 22),
                        padding: const EdgeInsets.all(16),
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
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: isDark ? Colors.white : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Attempted: $total • Correct: $correct • Wrong: $wrong',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 180,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 60,
                                  sections: [
                                    PieChartSectionData(
                                      color: AppColors.success,
                                      value: correct.toDouble(),
                                      title: 'Correct\n$correct',
                                      radius: 40,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: AppColors.danger,
                                      value: wrong.toDouble(),
                                      title: 'Wrong\n$wrong',
                                      radius: 40,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 22),
                  const Divider(color: AppColors.line),
                  const SizedBox(height: 12),

                  // ✅ ALL USERS IN-PROGRESS SESSIONS (Admin View)
                  const SectionHeader(
                    eyebrow: 'Live',
                    title: '📌 In-Progress Quizzes (All Users)',
                    subtitle: 'Users who started but haven\'t finished yet.',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: StorageService.getAllResumeSessionsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.danger,
                              ),
                            ),
                          );
                        }
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No one is currently in a quiz.',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final userName = data['userName'] ?? 'Anonymous';
                            final title = data['sectionTitle'] ?? 'Quiz';
                            final current = data['currentIndex'] ?? 0;
                            final total = data['totalQuestions'] ?? 0;
                            final isCurrentUser = userName == _userName;

                            return Container(
                              width: 220,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? (isDark
                                        ? const Color(0xFF0D3B2E)
                                        : AppColors.successSoft)
                                    : (isDark
                                        ? AppColors.darkCard
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCurrentUser
                                      ? AppColors.success
                                      : (isDark
                                          ? AppColors.darkLine
                                          : AppColors.line),
                                  width: isCurrentUser ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 14,
                                        color: isCurrentUser
                                            ? (isDark
                                                ? Colors.white
                                                : AppColors.ink)
                                            : (isDark
                                                ? AppColors.darkMuted
                                                : AppColors.muted),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: isCurrentUser
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 13,
                                            color: isCurrentUser
                                                ? (isDark
                                                    ? Colors.white
                                                    : AppColors.ink)
                                                : (isDark
                                                    ? Colors.white
                                                    : AppColors.ink),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isCurrentUser)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.success,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'YOU',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isCurrentUser
                                          ? (isDark
                                              ? Colors.white
                                              : AppColors.ink)
                                          : (isDark
                                              ? Colors.white
                                              : AppColors.ink),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline,
                                        size: 16,
                                        color: isCurrentUser
                                            ? (isDark
                                                ? Colors.white
                                                : AppColors.ink)
                                            : AppColors.accent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$current / $total',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isCurrentUser
                                              ? (isDark
                                                  ? Colors.white
                                                  : AppColors.ink)
                                              : AppColors.accent,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: current / total,
                                      minHeight: 4,
                                      color: isCurrentUser
                                          ? (isDark
                                              ? Colors.white
                                              : AppColors.ink)
                                          : AppColors.accent,
                                      backgroundColor: isDark
                                          ? AppColors.darkLine
                                          : AppColors.line,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ✅ Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.emoji_events_rounded),
                      label: const Text('🏆 View All Users Leaderboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.darkCard : AppColors.accentSoft,
                        foregroundColor:
                            isDark ? Colors.white : AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history_rounded),
                      label: const Text('📜 View All Users History'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkCard : null,
                        foregroundColor: isDark ? Colors.white : null,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
