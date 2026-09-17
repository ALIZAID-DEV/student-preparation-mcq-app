import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../models/category_model.dart';

class DataLoaderService {
  static const Map<String, Set<String>> _subjectAliases = {
    'nts_analytics': {'nts_analytics', 'analytics', 'ca'},
    'nts_english': {'nts_english', 'english'},
    'nts_gk': {'nts_gk', 'gk'},
    'sts_gk': {
      'sts_gk',
      'sindh_gk',
      'science',
      's',
      'pak_studies',
      'p',
      'islamiyat',
      'i'
    },
    'sts_math': {'sts_math', 'm', 'math'},
    'sts_english': {'sts_english', 'english', 'u'},
    'shc_computer': {'shc_computer', 'c', 'computer'},
    'shc_english': {'shc_english', 'english'},
    'shc_general': {
      'shc_general',
      'gk',
      'l',
      'sindh_gk',
      'pak_studies',
      'islamiyat',
      'i',
      'p'
    },
    'uni_physics': {'uni_physics', 'physics'},
    'uni_math': {'uni_math', 'math'},
    'uni_chemistry': {'uni_chemistry', 'chemistry'},
    'joa_mock_1': {
      'joa_mock_1',
      'joa_english',
      'joa_vocab',
      'joa_analytical',
      'joa_computer',
      'joa_math',
      'joa_general'
    },
    'joa_mock_2': {
      'joa_mock_2',
      'joa_english',
      'joa_vocab',
      'joa_analytical',
      'joa_computer',
      'joa_math',
      'joa_general'
    },
    'joa_mock_3': {
      'joa_mock_3',
      'joa_english',
      'joa_vocab',
      'joa_analytical',
      'joa_computer',
      'joa_math',
      'joa_general'
    },
  };

  static const Map<String, Set<String>> _categoryAliases = {
    'nts_exam': {'nts_exam', 'nts'},
    'sts_exam': {'sts_exam', 'sts_iba', 'sindh_jobs'},
    'sindh_high_court': {'sindh_high_court', 'g', 'sindh_jobs'},
    'university_test': {'university_test', 'university'},
  };

  static bool _subjectMatches(String questionSubjectId, String subCategoryId) {
    final aliases = _subjectAliases[subCategoryId];
    if (aliases != null) {
      return aliases.contains(questionSubjectId.trim());
    }
    return questionSubjectId.trim() == subCategoryId.trim();
  }

  static bool _categoryMatches(String questionCategoryId, String categoryId) {
    if (questionCategoryId.trim().isEmpty) return false;
    final aliases = _categoryAliases[categoryId];
    if (aliases != null) {
      return aliases.contains(questionCategoryId.trim());
    }
    return questionCategoryId.trim() == categoryId.trim();
  }

  static String _questionKey(Question question) {
    final id = question.id.trim();
    if (id.isNotEmpty) return 'id:$id';
    return '${question.categoryId}|${question.subjectId}|${question.question.trim().toLowerCase()}';
  }

  static Future<List<Question>> loadQuestions(String fileName) async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/$fileName');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      foundation.debugPrint('⚠️ Error loading $fileName: $e');
      return [];
    }
  }

  static Future<List<Question>> loadAllQuestions() async {
    final seen = <String, Question>{};
    final files = [
      'questions.json',
      'nts_questions.json',
      'sts_questions.json',
      'shc_questions.json',
      'uni_questions.json',
      'mock_test_1.json',
      'mock_test_2.json',
      'mock_test_3.json',
    ];
    for (final file in files) {
      final loaded = await loadQuestions(file);
      for (final question in loaded) {
        final key = _questionKey(question);
        seen.putIfAbsent(key, () => question);
      }
    }
    return seen.values.toList();
  }

  static Future<List<Question>> loadQuestionsForCategory(
      String categoryId, String subCategoryId) async {
    List<Question> all = await loadAllQuestions();
    return all.where((q) {
      return _subjectMatches(q.subjectId, subCategoryId) &&
          _categoryMatches(q.categoryId, categoryId);
    }).toList();
  }

  static Future<List<Category>> loadCategories() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/categories.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      foundation.debugPrint('⚠️ Error loading categories.json: $e');
      return [];
    }
  }
}
