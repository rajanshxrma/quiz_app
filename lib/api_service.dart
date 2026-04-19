import 'dart:convert';
import 'package:http/http.dart' as http;
import 'question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions() async {
    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((item) => Question.fromJson(item)).toList();
      } else {
        throw Exception('failed to load questions');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }
}
