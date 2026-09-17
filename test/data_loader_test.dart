import 'package:flutter_test/flutter_test.dart';
import 'package:student_preparation_app/services/data_loader_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads a broader question pool without duplicates', () async {
    final questions = await DataLoaderService.loadAllQuestions();

    expect(questions, isNotEmpty);
    final ids = questions.map((q) => q.id).toList();
    expect(ids.length, ids.toSet().length);
    expect(ids.contains('1'), isTrue);
  });
}
