import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/api_client.dart';

class LearningProvider extends ChangeNotifier {
  ApiClient _apiClient;
  List<dynamic> _sessions = [];
  Map<String, dynamic> _lessons = {};
  Set<String> _passedSessionIds = {};
  bool _isLoading = false;

  LearningProvider(this._apiClient);

  void updateApiClient(ApiClient newClient) {
    _apiClient = newClient;
  }

  List<dynamic> get sessions => _sessions;
  Map<String, dynamic> get lessons => _lessons;
  Set<String> get passedSessionIds => _passedSessionIds;
  bool get isLoading => _isLoading;

  Future<void> fetchAvailableSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get('/history/sessions/available');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessions = data['sessions'];
        _lessons = {for (var l in data['lessons']) l['id'].toString(): l};
        _passedSessionIds = Set<String>.from(
          data['passed_session_ids'].map((id) => id.toString()),
        );
      } else {
        debugPrint(
          '❌ Error fetching available sessions: ${response.statusCode}',
        );
        debugPrint('❌ Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Exception fetching available sessions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<dynamic>?> getSessionQuestions(String sessionId) async {
    try {
      final response = await _apiClient.get(
        '/learning/session/questions?session_id=$sessionId',
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['questions'];
      }
    } catch (e) {
      debugPrint('Error fetching session questions: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> startSession(String sessionId) async {
    try {
      final response = await _apiClient.post(
        '/learning/session/start',
        body: {'session_id': sessionId},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error starting session: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> submitAnswer({
    required String questionId,
    required String answer,
    required String historyId,
    required String startedAt,
  }) async {
    try {
      final response = await _apiClient.post(
        '/learning/question/answer',
        body: {
          'question_id': questionId,
          'answer': answer,
          'user_session_history_id': historyId,
          'started_at': startedAt,
          'asked_for_explanation': false,
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error submitting answer: $e');
    }
    return null;
  }

  Future<bool> finishSession(String historyId) async {
    try {
      final response = await _apiClient.post(
        '/learning/session/finish',
        body: {'history_id': historyId, 'passed': true},
      );
      if (response.statusCode == 200) {
        await fetchAvailableSessions();
        return true;
      }
    } catch (e) {
      debugPrint('Error finishing session: $e');
    }
    return false;
  }
}
