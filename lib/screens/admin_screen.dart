import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ui_kit.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final String _selectedSection = 'All';
  String _currentUserName = '';

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
        title: const Text('🔐 Admin Panel'),
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
                const Icon(Icons.admin_panel_settings,
                    size: 16, color: AppColors.accent),
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
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // ✅ Admin Stats Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('quizResults')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final docs = snapshot.data!.docs;
                  final totalUsers = docs
                      .map((d) => d['userName'] as String? ?? 'Anonymous')
                      .toSet()
                      .length;
                  final totalAttempts = docs.length;

                  int totalCorrect = 0;
                  int totalWrong = 0;
                  for (var doc in docs) {
                    totalCorrect += (doc['correct'] ?? 0) as int;
                    totalWrong += (doc['wrong'] ?? 0) as int;
                  }

                  return Row(
                    children: [
                      _buildStatCard(
                          '👥 Users', totalUsers.toString(), AppColors.accent),
                      const SizedBox(width: 8),
                      _buildStatCard('📝 Attempts', totalAttempts.toString(),
                          AppColors.success),
                      const SizedBox(width: 8),
                      _buildStatCard('✅ Correct', totalCorrect.toString(),
                          AppColors.success),
                    ],
                  );
                },
              ),
            ),

            // ✅ Tabs
            const TabBar(
              tabs: [
                Tab(text: '📊 Leaderboard'),
                Tab(text: '📜 History'),
                Tab(text: '⏳ In-Progress'),
              ],
            ),

            // ✅ Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildLeaderboardTab(isDark),
                  _buildHistoryTab(isDark),
                  _buildInProgressTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============= LEADERBOARD TAB =============
  Widget _buildLeaderboardTab(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('quizResults').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final Map<String, Map<String, dynamic>> userStats = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final userName = data['userName'] ?? 'Anonymous';
          final sectionId = data['sectionId'] ?? '';
          final correct = (data['correct'] ?? 0) as int;
          final wrong = (data['wrong'] ?? 0) as int;
          final total = (data['total'] ?? 0) as int;

          if (_selectedSection != 'All' && sectionId != _selectedSection) {
            continue;
          }

          if (!userStats.containsKey(userName)) {
            userStats[userName] = {
              'totalCorrect': 0,
              'totalWrong': 0,
              'totalAttempted': 0,
              'totalQuestions': 0,
              'quizCount': 0,
            };
          }

          userStats[userName]!['totalCorrect'] =
              userStats[userName]!['totalCorrect'] + correct;
          userStats[userName]!['totalWrong'] =
              userStats[userName]!['totalWrong'] + wrong;
          userStats[userName]!['totalAttempted'] =
              userStats[userName]!['totalAttempted'] + (correct + wrong);
          userStats[userName]!['totalQuestions'] =
              userStats[userName]!['totalQuestions'] + total;
          userStats[userName]!['quizCount'] =
              userStats[userName]!['quizCount'] + 1;
        }

        final sortedEntries = userStats.entries.toList()
          ..sort((a, b) => (b.value['totalCorrect'] ?? 0)
              .compareTo(a.value['totalCorrect'] ?? 0));

        if (sortedEntries.isEmpty) {
          return const Center(child: Text('No data found.'));
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
            final totalQuestions = stats['totalQuestions'] ?? 0;
            final quizCount = stats['quizCount'] ?? 0;
            final pct =
                totalQuestions == 0 ? 0 : (totalCorrect / totalQuestions * 100);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? AppColors.darkLine : AppColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: index < 3
                          ? [AppColors.accent, Colors.grey, Colors.brown][index]
                              .withValues(alpha: 0.2)
                          : AppColors.mist,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                        Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.ink,
                          ),
                        ),
                        Text(
                          '$quizCount quizzes • $totalQuestions total',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
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
                          color:
                              pct >= 70 ? AppColors.success : AppColors.accent,
                        ),
                      ),
                      Text(
                        '✅ $totalCorrect  ❌ $totalWrong',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============= HISTORY TAB =============
  Widget _buildHistoryTab(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: StorageService.getAllUsersHistoryStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('No history found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final userName = data['userName'] ?? 'Anonymous';
            final title = data['sectionTitle'] ?? 'Unknown';
            final correct = (data['correct'] ?? 0) as int;
            final wrong = (data['wrong'] ?? 0) as int;
            final total = (data['total'] ?? 0) as int;
            final timestamp = data['timestamp'] as Timestamp?;
            final date = timestamp?.toDate() ?? DateTime.now();

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? AppColors.darkLine : AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.ink,
                              ),
                            ),
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(total == 0 ? 0 : correct / total * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildAdminStatChip('✅ $correct', AppColors.success),
                      const SizedBox(width: 8),
                      _buildAdminStatChip('❌ $wrong', AppColors.danger),
                      const SizedBox(width: 8),
                      _buildAdminStatChip('📝 $total', AppColors.muted),
                      const SizedBox(width: 8),
                      _buildAdminStatChip(
                        '${date.day}/${date.month}/${date.year}',
                        AppColors.muted,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============= IN-PROGRESS TAB =============
  Widget _buildInProgressTab(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: StorageService.getAllResumeSessionsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('No one is currently in a quiz.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final userName = data['userName'] ?? 'Anonymous';
            final title = data['sectionTitle'] ?? 'Quiz';
            final current = data['currentIndex'] ?? 0;
            final total = data['totalQuestions'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? AppColors.darkLine : AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$current / $total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: current / total,
                      minHeight: 4,
                      color: AppColors.accent,
                      backgroundColor:
                          isDark ? AppColors.darkLine : AppColors.line,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdminStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
