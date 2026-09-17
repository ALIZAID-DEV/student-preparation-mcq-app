import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ui_kit.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _currentUserName = '';
  String _selectedSection = 'All';

  final Map<String, String> _sectionNames = {
    'All': '📊 All Sections',
    'nts_analytics': '🧠 Analytical Reasoning',
    'nts_english': '📝 NTS English Prep',
    'nts_gk': '🌍 General Knowledge',
    'sts_gk': '🏛️ STS GK',
    'sts_math': '🔢 STS Math',
    'sts_english': '📖 STS English',
    'shc_computer': '💻 SHC Computer',
    'shc_english': '📚 SHC English',
    'shc_general': '⚖️ SHC General',
    'uni_physics': '⚛️ Physics',
    'uni_math': '📐 Mathematics',
    'uni_chemistry': '🧪 Chemistry',
  };

  final List<String> _sections = [
    'All',
    'nts_analytics',
    'nts_english',
    'nts_gk',
    'sts_gk',
    'sts_math',
    'sts_english',
    'shc_computer',
    'shc_english',
    'shc_general',
    'uni_physics',
    'uni_math',
    'uni_chemistry',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await StorageService.getUserName();
    if (mounted) {
      setState(() => _currentUserName = name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SoftScaffold(
      appBar: AppBar(
        title: const Text('🏆 All Users Leaderboard'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  '👤 $_currentUserName',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkLine : AppColors.line,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSection,
                  isExpanded: true,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _sections.map((section) {
                    return DropdownMenuItem<String>(
                      value: section,
                      child: Text(_sectionNames[section] ?? section),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSection = value);
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quizResults')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 56, color: AppColors.danger),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined,
                            size: 64, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text(
                          'No attempts yet!',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete a quiz to appear on leaderboard!',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                final Map<String, Map<String, dynamic>> userStats = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final userName = data['userName'] ?? 'Anonymous';
                  final sectionId = data['sectionId'] ?? '';
                  final correct = (data['correct'] ?? 0) as int;
                  final wrong = (data['wrong'] ?? 0) as int;
                  final total = (data['total'] ?? 0) as int;

                  if (_selectedSection != 'All' &&
                      sectionId != _selectedSection) {
                    continue;
                  }

                  if (!userStats.containsKey(userName)) {
                    userStats[userName] = {
                      'totalCorrect': 0,
                      'totalWrong': 0,
                      'totalAttempted': 0,
                      'totalQuestions': 0,
                      'quizCount': 0,
                      'sections': <String>{},
                    };
                  }

                  userStats[userName]!['totalCorrect'] =
                      userStats[userName]!['totalCorrect'] + correct;
                  userStats[userName]!['totalWrong'] =
                      userStats[userName]!['totalWrong'] + wrong;
                  userStats[userName]!['totalAttempted'] =
                      userStats[userName]!['totalAttempted'] +
                          (correct + wrong);
                  userStats[userName]!['totalQuestions'] =
                      userStats[userName]!['totalQuestions'] + total;
                  userStats[userName]!['quizCount'] =
                      userStats[userName]!['quizCount'] + 1;
                  userStats[userName]!['sections'].add(sectionId);
                }

                final sortedEntries = userStats.entries.toList()
                  ..sort((a, b) => (b.value['totalCorrect'] ?? 0)
                      .compareTo(a.value['totalCorrect'] ?? 0));

                if (sortedEntries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            size: 56, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text('No attempts in this section yet!'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = sortedEntries[index];
                    final userName = entry.key;
                    final stats = entry.value;
                    final totalCorrect = stats['totalCorrect'] ?? 0;
                    final totalWrong = stats['totalWrong'] ?? 0;
                    final totalAttempted = stats['totalAttempted'] ?? 0;
                    final totalQuestions = stats['totalQuestions'] ?? 0;
                    final quizCount = stats['quizCount'] ?? 0;
                    final sections = stats['sections'] as Set<String>;
                    final pct = totalQuestions == 0
                        ? 0
                        : (totalCorrect / totalQuestions * 100);
                    final isCurrentUser = userName == _currentUserName;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // ✅ FIX: Dark mode mein current user ka background dark + text white
                        color: isCurrentUser
                            ? (isDark
                                ? const Color(
                                    0xFF0D3B2E) // Dark green background
                                : AppColors.successSoft)
                            : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrentUser
                              ? AppColors.success
                              : (isDark ? AppColors.darkLine : AppColors.line),
                          width: isCurrentUser ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: index < 3
                                      ? [
                                          AppColors.accent,
                                          Colors.grey,
                                          Colors.brown
                                        ][index]
                                          .withValues(alpha: 0.2)
                                      : AppColors.mist,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '#${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: index < 3
                                          ? [
                                              AppColors.accent,
                                              Colors.grey[600],
                                              Colors.brown
                                            ][index]
                                          : AppColors.muted,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            // ✅ Dark mode mein text white
                                            color: isCurrentUser
                                                ? Colors.white
                                                : (isDark
                                                    ? Colors.white
                                                    : AppColors.ink),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (isCurrentUser)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.success,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'YOU',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$quizCount quizzes • $totalAttempted attempts',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isCurrentUser
                                            ? Colors.white
                                                .withValues(alpha: 0.7)
                                            : AppColors.muted,
                                      ),
                                    ),
                                    if (sections.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Wrap(
                                          spacing: 4,
                                          runSpacing: 2,
                                          children: sections.map((s) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 1),
                                              decoration: BoxDecoration(
                                                color: isCurrentUser
                                                    ? Colors.white
                                                        .withValues(alpha: 0.15)
                                                    : AppColors.accentSoft,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                _sectionNames[s] ?? s,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: isCurrentUser
                                                      ? Colors.white.withValues(
                                                          alpha: 0.8)
                                                      : AppColors.accent,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${pct.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: pct >= 70
                                          ? AppColors.success
                                          : AppColors.accent,
                                    ),
                                  ),
                                  Text(
                                    '✅ $totalCorrect  ❌ $totalWrong',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCurrentUser
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
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
                                          'Progress',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isCurrentUser
                                                ? Colors.white
                                                    .withValues(alpha: 0.7)
                                                : AppColors.muted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '$totalCorrect / $totalQuestions correct',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isCurrentUser
                                                ? Colors.white
                                                    .withValues(alpha: 0.7)
                                                : AppColors.muted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: totalQuestions == 0
                                            ? 0
                                            : totalCorrect / totalQuestions,
                                        minHeight: 8,
                                        backgroundColor: isDark
                                            ? AppColors.darkLine
                                            : AppColors.line,
                                        color: pct >= 70
                                            ? AppColors.success
                                            : AppColors.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$totalCorrect correct out of $totalQuestions total',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isCurrentUser
                                            ? Colors.white
                                                .withValues(alpha: 0.7)
                                            : AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (totalWrong > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '❌ Wrong answers: $totalWrong',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isCurrentUser
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : AppColors.danger,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }
}
