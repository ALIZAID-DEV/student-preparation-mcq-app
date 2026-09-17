class Question {
  final String id;
  final String categoryId;
  final String subjectId;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  late List<String> shuffledOptions;
  late int shuffledCorrectIndex;

  Question({
    required this.id,
    required this.categoryId,
    required this.subjectId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  }) {
    shuffledOptions = options;
    shuffledCorrectIndex = correctAnswerIndex;
  }

  // ✅ Har baar naya shuffle karne ke liye
  void shuffleOptions() {
    if (options.isEmpty) {
      shuffledOptions = <String>[];
      shuffledCorrectIndex = 0;
      return;
    }
    final indexed = <(String, int)>[];
    for (int i = 0; i < options.length; i++) {
      indexed.add((options[i], i));
    }
    indexed.shuffle();
    shuffledOptions = indexed.map((e) => e.$1).toList();
    shuffledCorrectIndex =
        indexed.indexWhere((e) => e.$2 == correctAnswerIndex);
  }

  // ✅ Save ki hui shuffled order wapas lagane ke liye
  void applyShuffledOrder(
      List<String> newShuffledOptions, int newShuffledCorrectIndex) {
    shuffledOptions = newShuffledOptions;
    shuffledCorrectIndex = newShuffledCorrectIndex;
  }

  // ✅ Original order preserve karne ke liye clone
  Question copyWith() {
    return Question(
      id: id,
      categoryId: categoryId,
      subjectId: subjectId,
      question: question,
      options: List<String>.from(options),
      correctAnswerIndex: correctAnswerIndex,
      explanation: explanation,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      subjectId: (json['subjectId'] ?? json['subCategoryId'] ?? '') as String,
      question: json['question'] as String? ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'subjectId': subjectId,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }
}
