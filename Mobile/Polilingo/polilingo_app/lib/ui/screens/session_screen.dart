import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/app_colors.dart';
import '../../providers/learning_provider.dart';
import '../../providers/auth_provider.dart';
import 'session_summary_screen.dart';

class SessionScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  const SessionScreen({super.key, required this.session});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  List<dynamic> _questions = [];
  List<dynamic> _toRetry = [];
  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnswered = false;
  bool _isCorrect = false;
  Map<String, dynamic>? _answerResult;
  String? _historyId;
  int _lives = 5;
  bool _isLoading = true;
  bool _isRetryRound = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    final learning = context.read<LearningProvider>();
    final qs = await learning.getSessionQuestions(
      widget.session['id'].toString(),
    );
    final startData = await learning.startSession(
      widget.session['id'].toString(),
    );

    if (qs != null && startData != null) {
      setState(() {
        _questions = qs;
        _historyId = startData['id'].toString();
        _lives = startData['lives_remaining'] ?? 5;
        _isLoading = false;
      });
    } else {
      // Handle error
      if (mounted) Navigator.pop(context);
    }
  }

  void _checkAnswer() async {
    if (_selectedOption == null) return;

    final learning = context.read<LearningProvider>();
    final currentQuestion = _isRetryRound
        ? _toRetry[_currentIndex]
        : _questions[_currentIndex];

    final result = await learning.submitAnswer(
      questionId: currentQuestion['id'].toString(),
      answer: _selectedOption!,
      historyId: _historyId!,
      startedAt: DateTime.now().toUtc().toIso8601String(),
    );

    if (result != null) {
      setState(() {
        _answerResult = result;
        _isAnswered = true;
        _isCorrect = result['correct'];
        _lives = result['lives_remaining'];
      });

      if (!_isCorrect) {
        _toRetry.add(currentQuestion);
      }
    }
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _isAnswered = false;
      _answerResult = null;

      if (_isRetryRound) {
        if (_currentIndex >= _toRetry.length) {
          _finishSession();
        }
      } else {
        if (_currentIndex >= _questions.length) {
          if (_toRetry.isNotEmpty) {
            _startRetryRound();
          } else {
            _finishSession();
          }
        }
      }
    });
  }

  void _startRetryRound() {
    setState(() {
      _isRetryRound = true;
      _currentIndex = 0;
      // We don't clear _toRetry here because we need to retry them,
      // but the submitAnswer logic will add failed ones back if we wanted endless retries.
      // In the python app, it seems to do rounds.
      // Let's copy the python logic: round-based retry.
      final currentRetry = List.from(_toRetry);
      _toRetry = [];
      _questions =
          currentRetry; // Re-use _questions for the retry round display
    });
  }

  Future<void> _finishSession() async {
    setState(() => _isLoading = true);
    await context.read<LearningProvider>().finishSession(_historyId!);
    if (mounted) {
      await context.read<AuthProvider>().checkProfile(); // Refresh stats
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SessionSummaryScreen(stats: {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentQuestion = _isRetryRound
        ? _questions[_currentIndex]
        : _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(progress),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuestionCard(currentQuestion['question']),
                        const SizedBox(height: 32),
                        _buildOption(currentQuestion, 'a'),
                        const SizedBox(height: 12),
                        _buildOption(currentQuestion, 'b'),
                        const SizedBox(height: 12),
                        _buildOption(currentQuestion, 'c'),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),

          if (_isAnswered) _buildFeedbackOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$_lives',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String text) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildOption(Map<String, dynamic> q, String key) {
    bool isSelected = _selectedOption == key;
    return GestureDetector(
      onTap: _isAnswered ? null : () => setState(() => _selectedOption = key),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white12,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white30,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                q[key],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _selectedOption == null || _isAnswered ? null : _checkAnswer,
        child: const Text('CHECK ANSWER'),
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    final color = _isCorrect ? Colors.green : Colors.red;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isCorrect ? const Color(0xFF0F2B1D) : const Color(0xFF2A1313),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: color.withOpacity(0.3))),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isCorrect ? Icons.check_circle : Icons.cancel,
              color: color,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _isCorrect ? '¡Respuesta Correcta!' : 'Incorrect!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!_isCorrect) ...[
              const SizedBox(height: 8),
              const Text(
                'Don\'t worry, keep practicing.',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 24),
              _buildCorrectAnswerBox(),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCorrect ? AppColors.primary : Colors.white,
                foregroundColor: _isCorrect ? Colors.white : Colors.black,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentIndex == _questions.length - 1
                        ? 'FINISH SESSION'
                        : 'CONTINUE',
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectAnswerBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Correct Answer',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _answerResult?['explanation'] ??
                      'The correct answer was ${_answerResult?['correct_answer']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
