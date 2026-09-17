import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/storage_service.dart';
import '../widgets/ui_kit.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
        title: const Text('📜 All Users History'),
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
          // ✅ Section Filter Dropdown
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
          // ✅ History List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: StorageService.getAllUsersHistoryStream(),
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

                final filteredDocs = _selectedSection == 'All'
                    ? docs
                    : docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final sectionId = data['sectionId'] ?? '';
                        return sectionId == _selectedSection;
                      }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            size: 56, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text(
                          'No attempts in this section yet!',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    final userName = data['userName'] ?? 'Anonymous';
                    final title = data['sectionTitle'] ?? 'Unknown';
                    final sectionId = data['sectionId'] ?? '';
                    final correct = (data['correct'] ?? 0) as int;
                    final wrong = (data['wrong'] ?? 0) as int;
                    final total = (data['total'] ?? 0) as int;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final date = timestamp?.toDate() ?? DateTime.now();

                    final pct = total == 0 ? 0 : (correct / total * 100);
                    final isCurrentUser = userName == _currentUserName;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? (isDark
                                ? const Color(0xFF0D3B2E)
                                : AppColors.successSoft)
                            : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrentUser
                              ? AppColors.success
                              : (isDark ? AppColors.darkLine : AppColors.line),
                          width: isCurrentUser ? 2 : 1,
                        ),
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
                                        fontSize: 16,
                                        // ✅ Light mode: black, Dark mode: white
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
                                    Text(
                                      _sectionNames[sectionId] ?? sectionId,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isCurrentUser
                                            ? (isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.8)
                                                : AppColors.ink
                                                    .withValues(alpha: 0.7))
                                            : AppColors.accent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: pct >= 70
                                      ? AppColors.successSoft
                                      : AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: pct >= 70
                                        ? AppColors.success
                                        : AppColors.accent,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                // ✅ Light mode: black, Dark mode: white
                                color: isCurrentUser
                                    ? (isDark ? Colors.white : AppColors.ink)
                                    : AppColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    // ✅ Light mode: black, Dark mode: white
                                    color: isCurrentUser
                                        ? (isDark
                                            ? Colors.white
                                            : AppColors.ink)
                                        : AppColors.muted,
                                    fontSize: 14,
                                    fontWeight: isCurrentUser
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isCurrentUser)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildStatChip(
                                '✅ Correct',
                                correct.toString(),
                                isCurrentUser
                                    ? (isDark ? Colors.white : AppColors.ink)
                                    : AppColors.success,
                                isDark,
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                '❌ Wrong',
                                wrong.toString(),
                                isCurrentUser
                                    ? (isDark ? Colors.white : AppColors.ink)
                                    : AppColors.danger,
                                isDark,
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                '📝 Total',
                                total.toString(),
                                isCurrentUser
                                    ? (isDark ? Colors.white : AppColors.ink)
                                    : AppColors.muted,
                                isDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: isCurrentUser
                                    ? (isDark
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : AppColors.ink.withValues(alpha: 0.5))
                                    : AppColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? (isDark
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : AppColors.ink
                                              .withValues(alpha: 0.5))
                                      : AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isCurrentUser
                                    ? (isDark
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : AppColors.ink.withValues(alpha: 0.5))
                                    : AppColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? (isDark
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : AppColors.ink
                                              .withValues(alpha: 0.5))
                                      : AppColors.muted,
                                  fontSize: 12,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
