import 'question_model.dart';

class WrongAnswer {
  final Question question;
  final int selectedIndex;

  const WrongAnswer({required this.question, required this.selectedIndex});
}
