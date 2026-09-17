import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question_model.dart';

class StorageService {
  static const String _bookmarkKey = 'bookmarked_questions';
  static const String _progressKey = 'quiz_progress_data';
  static const String _sessionKey = 'quiz_session_state';

  // 🔥 User Name get karna
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Anonymous';
  }

  // 🔥 User Name save karna (Naya method)
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    debugPrint('✅ User name saved: $name');
  }

  // ============= CLOUD RESUME SESSIONS (In-Progress) =============

  // 🔥 Save karo ke user ne quiz start ki hai
  static Future<void> saveResumeSessionToCloud({
    required String sectionId,
    required String sectionTitle,
    required int currentIndex,
    required int totalQuestions,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final userName = await getUserName();

      await FirebaseFirestore.instance
          .collection('resumeSessions')
          .doc(user.uid)
          .set({
        'userName': userName,
        'uid': user.uid,
        'sectionId': sectionId,
        'sectionTitle': sectionTitle,
        'currentIndex': currentIndex,
        'totalQuestions': totalQuestions,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Cloud resume saved: $currentIndex/$totalQuestions');
    } catch (e) {
      debugPrint('❌ Cloud resume save error: $e');
    }
  }

  // 🔥 Clear karo jab quiz complete ho jaye
  static Future<void> clearResumeSessionFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('resumeSessions')
          .doc(user.uid)
          .delete();
      debugPrint('✅ Cloud resume cleared');
    } catch (e) {
      debugPrint('❌ Cloud resume clear error: $e');
    }
  }

  // 🔥 Sab users ki in-progress sessions (Admin ke liye)
  static Stream<QuerySnapshot> getAllResumeSessionsStream() {
    return FirebaseFirestore.instance
        .collection('resumeSessions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 🔥 Sirf current user ki in-progress session
  static Future<Map<String, dynamic>?> loadCloudResumeSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final doc = await FirebaseFirestore.instance
          .collection('resumeSessions')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        debugPrint('✅ Cloud resume loaded');
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Load cloud resume error: $e');
      return null;
    }
  }

  // ============= FIREBASE RESULTS (Finished Quizzes) =============

  // 🔥 Firestore mein result save
  static Future<void> saveQuizProgressToCloud({
    required String sectionId,
    required String sectionTitle,
    required int correct,
    required int wrong,
    required int total,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final userName = await getUserName();

      await FirebaseFirestore.instance.collection('quizResults').add({
        'uid': user.uid,
        'userName': userName,
        'sectionId': sectionId,
        'sectionTitle': sectionTitle,
        'correct': correct,
        'wrong': wrong,
        'total': total,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Result saved: $userName - $sectionTitle - $correct/$total');
    } catch (e) {
      debugPrint('❌ Cloud save error: $e');
    }
  }

  // 🔥 Firestore se sab users ki history (Stream)
  static Stream<QuerySnapshot> getAllUsersHistoryStream() {
    return FirebaseFirestore.instance
        .collection('quizResults')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ============= LOCAL BOOKMARKS =============
  static Future<List<String>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarkKey) ?? [];
  }

  static Future<bool> isBookmarked(String id) async {
    return (await getBookmarks()).contains(id);
  }

  static Future<void> toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final b = prefs.getStringList(_bookmarkKey) ?? [];
    if (b.contains(id)) {
      b.remove(id);
    } else {
      b.add(id);
    }
    await prefs.setStringList(_bookmarkKey, b);
  }

  // ============= LOCAL PROGRESS (Backup + Stats) =============
  static Future<void> saveQuizProgress({
    required String sectionId,
    required String sectionTitle,
    required int correct,
    required int wrong,
    required int total,
  }) async {
    // ✅ Cloud mein complete result save
    await saveQuizProgressToCloud(
      sectionId: sectionId,
      sectionTitle: sectionTitle,
      correct: correct,
      wrong: wrong,
      total: total,
    );

    // ✅ Quiz complete hone par cloud resume session clear karo
    await clearResumeSessionFromCloud();

    // ✅ Local backup
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(_progressKey);
    Map<String, dynamic> allData = jsonStr != null ? jsonDecode(jsonStr) : {};

    int totalQuizzes = allData['totalQuizCompleted'] ?? 0;
    allData['totalQuizCompleted'] = totalQuizzes + 1;

    allData['totalCorrectAll'] = (allData['totalCorrectAll'] ?? 0) + correct;
    allData['totalWrongAll'] = (allData['totalWrongAll'] ?? 0) + wrong;
    allData['totalAttemptedAll'] = (allData['totalAttemptedAll'] ?? 0) + total;

    if (!allData.containsKey(sectionId)) {
      allData[sectionId] = {
        'title': sectionTitle,
        'totalCorrect': 0,
        'totalWrong': 0,
        'totalAttempted': 0,
        'history': [],
      };
    }

    final sectionData = allData[sectionId];
    sectionData['totalCorrect'] = sectionData['totalCorrect'] + correct;
    sectionData['totalWrong'] = sectionData['totalWrong'] + wrong;
    sectionData['totalAttempted'] = sectionData['totalAttempted'] + total;

    List<dynamic> history = sectionData['history'] ?? [];
    history.add({
      'title': sectionTitle,
      'correct': correct,
      'wrong': wrong,
      'total': total,
      'date': DateTime.now().toIso8601String(),
    });
    if (history.length > 20) {
      history = history.sublist(history.length - 20);
    }
    sectionData['history'] = history;

    await prefs.setString(_progressKey, jsonEncode(allData));
  }

  static Future<Map<String, dynamic>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return {};
    return jsonDecode(jsonStr);
  }

  // ============= LOCAL QUIZ SESSION (Resume ke liye) =============
  static Future<void> saveQuizSession({
    required String sectionId,
    required int currentIndex,
    required List<Map<String, dynamic>?> userAnswers,
    required List<Question> questions,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final questionsSnapshot = questions
          .map((q) => ({
                'id': q.id,
                'shuffledOptions': q.shuffledOptions,
                'shuffledCorrectIndex': q.shuffledCorrectIndex,
              }))
          .toList();

      final answersToSave = userAnswers.map((answer) {
        if (answer == null) return null;
        return {
          'questionId': answer['question']?.id ?? '',
          'selectedIndex': answer['selectedIndex'],
          'isCorrect': answer['isCorrect'],
        };
      }).toList();

      final data = {
        'sectionId': sectionId,
        'currentIndex': currentIndex,
        'userAnswers': answersToSave,
        'questionsSnapshot': questionsSnapshot,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_sessionKey, jsonEncode(data));
      debugPrint('💾 Session saved: ${currentIndex + 1}/${questions.length}');
    } catch (e) {
      debugPrint('❌ Save session error: $e');
    }
  }

  static Future<Map<String, dynamic>?> loadQuizSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_sessionKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        debugPrint('📂 No local session found');
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(jsonStr);
      debugPrint('📂 Local session loaded');
      return data;
    } catch (e) {
      debugPrint('❌ Load session error: $e');
      return null;
    }
  }

  static Future<void> clearQuizSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      debugPrint('🗑️ Session cleared');
    } catch (e) {
      debugPrint('❌ Clear session error: $e');
    }
  }
}
