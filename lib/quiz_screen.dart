import 'package:flutter/material.dart';
import 'question.dart';
import 'api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  bool _loading = true;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // fetch questions from api
  void _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions: $e')),
        );
      }
    }
  }

  // check if selected answer is correct
  void _answerQuestion(String selected) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswer = selected;
      if (selected == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  // move to next question
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
    }
  }

  // restart the quiz
  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
      _loading = true;
    });
    _loadQuestions();
  }

  // get button color based on answer state
  Color _getButtonColor(String option) {
    if (!_answered) return Colors.blue;
    if (option == _questions[_currentQuestionIndex].correctAnswer) {
      return Colors.green;
    }
    if (option == _selectedAnswer) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Could not load questions.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _restartQuiz,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // show final score screen
    if (_currentQuestionIndex >= _questions.length - 1 && _answered) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Complete')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                'Your Score',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                '$_score / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _restartQuiz,
                icon: const Icon(Icons.refresh),
                label: const Text('Play Again'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // question text
            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // answer buttons
            ...question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: _answered ? null : () => _answerQuestion(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(option),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _getButtonColor(option),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              );
            }),

            const Spacer(),

            // next button
            if (_answered && _currentQuestionIndex < _questions.length - 1)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Next Question', style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}
