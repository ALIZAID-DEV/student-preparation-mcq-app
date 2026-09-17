import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../models/wrong_answer.dart';
import '../services/data_loader_service.dart';
import '../services/ad_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/ui_kit.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final String subCategoryId;
  final String title;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.subCategoryId,
    required this.title,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int currentIndex = 0;
  int? selectedOption;
  bool showAnswerFeedback = false;
  bool isLoading = true;
  String? _error;

  List<Map<String, dynamic>?> userAnswers = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();

    if (!kIsWeb) {
      try {
        AdService.loadInterstitialAd();
      } catch (e) {
        debugPrint('Interstitial pre-load skipped: $e');
      }
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      final List<Question> loadedQuestions =
          await DataLoaderService.loadQuestionsForCategory(
        widget.categoryId,
        widget.subCategoryId,
      );

      if (!mounted) return;

      if (loadedQuestions.isEmpty) {
        setState(() {
          isLoading = false;
          _error = 'No questions found for this section.';
        });
        return;
      }

      // ✅ Load saved session
      final Map<String, dynamic>? savedSession =
          await StorageService.loadQuizSession();

      // ✅ Check if we have a valid session for this section
      bool hasValidSession = savedSession != null &&
          savedSession['sectionId'] == widget.subCategoryId &&
          savedSession['questionsSnapshot'] != null &&
          savedSession['questionsSnapshot'] is List &&
          (savedSession['questionsSnapshot'] as List).isNotEmpty;

      if (hasValidSession) {
        try {
          final List<dynamic> sessionQuestions =
              savedSession['questionsSnapshot'] as List;
          final List<dynamic> sessionAnswers =
              savedSession['userAnswers'] as List? ?? [];
          final int savedIndex = savedSession['currentIndex'] ?? 0;

          // ✅ Clone and restore questions
          final List<Question> restoredQuestions =
              loadedQuestions.map((q) => q.copyWith()).toList();

          // ✅ Restore shuffled options for each question
          for (int i = 0;
              i < restoredQuestions.length && i < sessionQuestions.length;
              i++) {
            final snap = sessionQuestions[i];
            if (snap != null && snap['shuffledOptions'] != null) {
              restoredQuestions[i].applyShuffledOrder(
                List<String>.from(snap['shuffledOptions']),
                snap['shuffledCorrectIndex'] ?? 0,
              );
            }
          }

          // ✅ Restore user answers
          final List<Map<String, dynamic>?> restoredAnswers =
              List.filled(restoredQuestions.length, null);
          for (int i = 0;
              i < sessionAnswers.length && i < restoredAnswers.length;
              i++) {
            final answer = sessionAnswers[i];
            if (answer != null) {
              final String? qId = answer['questionId'] as String?;
              if (qId != null && qId.isNotEmpty) {
                final Question matchedQ = restoredQuestions.firstWhere(
                  (q) => q.id == qId,
                  orElse: () => restoredQuestions.first,
                );
                restoredAnswers[i] = {
                  'question': matchedQ,
                  'selectedIndex': answer['selectedIndex'],
                  'isCorrect': answer['isCorrect'],
                };
              }
            }
          }

          // ✅ Determine starting index
          int startIndex = savedIndex;
          if (startIndex >= restoredQuestions.length) {
            startIndex = 0;
          }

          setState(() {
            questions = restoredQuestions;
            userAnswers = restoredAnswers;
            currentIndex = startIndex;
            isLoading = false;
            _error = null;
          });

          // ✅ Restore selected option for current question
          if (userAnswers[currentIndex] != null) {
            selectedOption =
                userAnswers[currentIndex]!['selectedIndex'] as int?;
            showAnswerFeedback = true;
          }

          debugPrint(
              '✅ Session restored: Q${currentIndex + 1}/${questions.length}');
          return;
        } catch (e) {
          debugPrint('⚠️ Session restore error: $e');
        }
      }

      // ✅ Fresh start
      final List<Question> shuffledQuestions =
          loadedQuestions.map((q) => q.copyWith()).toList();
      shuffledQuestions.shuffle();
      for (final q in shuffledQuestions) {
        q.shuffleOptions();
      }

      await StorageService.clearQuizSession();
      await StorageService.clearResumeSessionFromCloud();

      setState(() {
        questions = shuffledQuestions;
        userAnswers = List.filled(questions.length, null);
        currentIndex = 0;
        selectedOption = null;
        showAnswerFeedback = false;
        isLoading = false;
        _error = null;
      });
      debugPrint('✅ Fresh start: ${questions.length} questions');
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          _error = 'Failed to load questions: $e';
        });
      }
    }
  }

  void _saveSession() {
    if (questions.isEmpty) return;

    try {
      StorageService.saveQuizSession(
        sectionId: widget.subCategoryId,
        currentIndex: currentIndex,
        userAnswers: userAnswers,
        questions: questions,
      );

      // ✅ Save to cloud too
      final bool hasAnswered = userAnswers.any((element) => element != null);
      if (hasAnswered || currentIndex > 0) {
        StorageService.saveResumeSessionToCloud(
          sectionId: widget.subCategoryId,
          sectionTitle: widget.title,
          currentIndex: currentIndex + 1,
          totalQuestions: questions.length,
        );
      }
    } catch (e) {
      debugPrint('⚠️ Save error: $e');
    }
  }

  @override
  void dispose() {
    _saveSession();
    super.dispose();
  }

  void _previousQuestion() {
    if (currentIndex <= 0) return;

    // Save current answer
    if (selectedOption != null && showAnswerFeedback) {
      final currentQuestion = questions[currentIndex];
      final isCorrect = selectedOption == currentQuestion.shuffledCorrectIndex;
      userAnswers[currentIndex] = {
        'question': currentQuestion,
        'selectedIndex': selectedOption,
        'isCorrect': isCorrect,
      };
    }

    setState(() {
      currentIndex--;
      final savedAnswer = userAnswers[currentIndex];
      if (savedAnswer != null) {
        selectedOption = savedAnswer['selectedIndex'] as int?;
        showAnswerFeedback = true;
      } else {
        selectedOption = null;
        showAnswerFeedback = false;
      }
    });
    _saveSession();
  }

  void _nextQuestion() {
    if (selectedOption == null || !showAnswerFeedback) return;

    // Save current answer
    final currentQuestion = questions[currentIndex];
    final isCorrect = selectedOption == currentQuestion.shuffledCorrectIndex;
    userAnswers[currentIndex] = {
      'question': currentQuestion,
      'selectedIndex': selectedOption,
      'isCorrect': isCorrect,
    };

    // Move to next or finish
    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
        final savedAnswer = userAnswers[currentIndex];
        if (savedAnswer != null) {
          selectedOption = savedAnswer['selectedIndex'] as int?;
          showAnswerFeedback = true;
        } else {
          selectedOption = null;
          showAnswerFeedback = false;
        }
      });
      _saveSession();
    } else {
      // 🔥 Quiz Complete
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    StorageService.clearResumeSessionFromCloud();

    if (!kIsWeb) {
      try {
        AdService.showInterstitialAd();
      } catch (_) {}
    }

    final wrongAnswers = userAnswers
        .where((entry) => entry != null && entry['isCorrect'] == false)
        .map((entry) => WrongAnswer(
              question: entry!['question'] as Question,
              selectedIndex: entry['selectedIndex'] as int,
            ))
        .toList();
    final finalScore = userAnswers
        .where((ans) => ans != null && ans['isCorrect'] == true)
        .length;

    StorageService.saveQuizProgress(
      sectionId: widget.subCategoryId,
      sectionTitle: widget.title,
      correct: finalScore,
      wrong: wrongAnswers.length,
      total: questions.length,
    );

    StorageService.clearQuizSession();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          quizTitle: widget.title,
          score: finalScore,
          total: questions.length,
          wrong: wrongAnswers.length,
          wrongAnswers: wrongAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDark;

        if (isLoading) {
          return SoftScaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading questions...')
                ])),
          );
        }

        if (_error != null || questions.isEmpty) {
          return SoftScaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 56, color: AppColors.danger),
                          const SizedBox(height: 14),
                          Text(
                            _error ?? 'No questions available.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.danger),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                _error = null;
                              });
                              _fetchQuestions();
                            },
                            child: const Text('Retry'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Go Back'),
                          ),
                        ]))),
          );
        }

        final currentQuestion = questions[currentIndex];
        final isLast = currentIndex + 1 == questions.length;
        final int answeredCount =
            userAnswers.where((element) => element != null).length;

        return SoftScaffold(
          appBar: AppBar(
            title: Text(widget.title),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            actions: [
              Container(
                constraints: const BoxConstraints(maxWidth: 100),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        '$answeredCount / ${questions.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
                  child: QuizProgressBar(
                    current: currentIndex + 1,
                    total: questions.length,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : Colors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: isDark
                                    ? AppColors.darkLine
                                    : AppColors.line),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.3 : 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question ${currentIndex + 1}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: AppColors.accent,
                                      fontSize: 12,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentQuestion.question,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(height: 1.35),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const AdBanner(),
                        const SizedBox(height: 18),
                        ...List.generate(
                          currentQuestion.shuffledOptions.length,
                          (index) {
                            final bool selectedThis = selectedOption == index;
                            final bool isCorrect =
                                index == currentQuestion.shuffledCorrectIndex;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OptionTile(
                                label: String.fromCharCode(65 + index),
                                text: currentQuestion.shuffledOptions[index],
                                selected: selectedThis,
                                correct: isCorrect,
                                showFeedback: showAnswerFeedback,
                                isSelectedWrong: showAnswerFeedback &&
                                    selectedThis &&
                                    !isCorrect,
                                onTap: selectedOption == null &&
                                        !showAnswerFeedback
                                    ? () => setState(() {
                                          selectedOption = index;
                                          showAnswerFeedback = true;
                                        })
                                    : null,
                              ),
                            );
                          },
                        ),
                        if (showAnswerFeedback) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selectedOption ==
                                      currentQuestion.shuffledCorrectIndex
                                  ? (isDark
                                      ? AppColors.darkSuccessSoft
                                      : AppColors.successSoft)
                                  : (isDark
                                      ? AppColors.darkDangerSoft
                                      : AppColors.dangerSoft),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedOption ==
                                        currentQuestion.shuffledCorrectIndex
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  selectedOption ==
                                          currentQuestion.shuffledCorrectIndex
                                      ? Icons.check_circle_rounded
                                      : Icons.error_rounded,
                                  color: selectedOption ==
                                          currentQuestion.shuffledCorrectIndex
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedOption ==
                                            currentQuestion.shuffledCorrectIndex
                                        ? 'Correct! ${currentQuestion.explanation}'
                                        : 'Wrong answer. Correct is ${String.fromCharCode(65 + currentQuestion.shuffledCorrectIndex)}. ${currentQuestion.explanation}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.ink,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (currentIndex > 0) ...[
                        OutlinedButton.icon(
                          onPressed: _previousQuestion,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Previous'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: selectedOption == null || !showAnswerFeedback
                            ? null
                            : _nextQuestion,
                        icon: Icon(isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded),
                        label: Text(isLast ? 'Finish Quiz' : 'Next Question'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
