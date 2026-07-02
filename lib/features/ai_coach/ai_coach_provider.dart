import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
  });

  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AiCoachState {
  final List<ChatSession> sessions;
  final String activeSessionId;
  final bool isTyping;
  final bool isLoading;
  final String? errorMessage;

  AiCoachState({
    required this.sessions,
    required this.activeSessionId,
    this.isTyping = false,
    this.isLoading = false,
    this.errorMessage,
  });

  ChatSession get activeSession =>
      sessions.firstWhere((s) => s.id == activeSessionId,
          orElse: () => ChatSession(
                id: 'default',
                title: 'New Coaching Session',
                messages: [],
                updatedAt: DateTime.now(),
              ));

  AiCoachState copyWith({
    List<ChatSession>? sessions,
    String? activeSessionId,
    bool? isTyping,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiCoachState(
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      isTyping: isTyping ?? this.isTyping,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  AiCoachNotifier()
      : super(AiCoachState(
          sessions: [],
          activeSessionId: '',
          isLoading: true,
        )) {
    _initFromBackend();
  }

  Future<void> _initFromBackend() async {
    try {
      final response = await apiClient.post(
        ApiConstants.tutorChatStart,
        body: {'context_type': 'coach'},
      );
      final reply = response['reply']?.toString() ?? 'Welcome to your AI Coach session.';
      final now = DateTime.now();
      final session = ChatSession(
        id: 'session_${now.millisecondsSinceEpoch}',
        title: 'AI Coach Session',
        messages: [
          ChatMessage(
            id: 'welcome',
            text: reply,
            isUser: false,
            timestamp: now,
          ),
        ],
        updatedAt: now,
      );
      state = AiCoachState(
        sessions: [session],
        activeSessionId: session.id,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = AiCoachState(
        sessions: [],
        activeSessionId: '',
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = AiCoachState(
        sessions: [],
        activeSessionId: '',
        isLoading: false,
        errorMessage: 'Failed to start AI Coach session.',
      );
    }
  }

  Future<void> startNewChat() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await apiClient.post(
        ApiConstants.tutorChatStart,
        body: {'context_type': 'coach'},
      );
      final reply = response['reply']?.toString() ?? 'New coaching session started.';
      final now = DateTime.now();
      final newSessionId = 'session_${now.millisecondsSinceEpoch}';
      final newSession = ChatSession(
        id: newSessionId,
        title: 'New Coaching Chat',
        messages: [
          ChatMessage(
            id: 'welcome',
            text: reply,
            isUser: false,
            timestamp: now,
          ),
        ],
        updatedAt: now,
      );

      state = state.copyWith(
        sessions: [newSession, ...state.sessions],
        activeSessionId: newSessionId,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  void selectSession(String sessionId) {
    state = state.copyWith(activeSessionId: sessionId);
  }

  void deleteSession(String sessionId) {
    final filtered = state.sessions.where((s) => s.id != sessionId).toList();
    String activeId = state.activeSessionId;
    if (activeId == sessionId) {
      activeId = filtered.isNotEmpty ? filtered.first.id : '';
    }
    state = state.copyWith(sessions: filtered, activeSessionId: activeId);
    if (filtered.isEmpty) {
      startNewChat();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedSessions = state.sessions.map((session) {
      if (session.id == state.activeSessionId) {
        String title = session.title;
        if (title == 'New Coaching Chat' || title == 'AI Coach Session') {
          title = text.length > 28 ? '${text.substring(0, 25)}...' : text;
        }
        return session.copyWith(
          messages: [...session.messages, userMessage],
          title: title,
          updatedAt: DateTime.now(),
        );
      }
      return session;
    }).toList();

    state = state.copyWith(sessions: updatedSessions, isTyping: true, clearError: true);

    final aiMessageId = 'm_${DateTime.now().millisecondsSinceEpoch}_ai';
    final aiMessage = ChatMessage(
      id: aiMessageId,
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );

    final sessionsWithEmptyAi = state.sessions.map((session) {
      if (session.id == state.activeSessionId) {
        return session.copyWith(
          messages: [...session.messages, aiMessage],
          updatedAt: DateTime.now(),
        );
      }
      return session;
    }).toList();

    state = state.copyWith(sessions: sessionsWithEmptyAi);

    try {
      final client = http.Client();
      final request = http.Request('POST', Uri.parse('${ApiClient.baseUrl}/api/v1/tutor/chat/continue/stream'));
      
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (apiClient.token != null) {
        headers['Authorization'] = 'Bearer ${apiClient.token}';
      }
      request.headers.addAll(headers);
      request.body = json.encode({
        'context_type': 'coach',
        'message': text,
      });

      final response = await client.send(request);
      
      if (response.statusCode != 200) {
        throw ApiException('Failed to establish stream connection.', statusCode: response.statusCode);
      }

      final accumulatedText = StringBuffer();
      
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        accumulatedText.write(chunk);
        
        final streamingSessions = state.sessions.map((session) {
          if (session.id == state.activeSessionId) {
            final updatedMsgs = session.messages.map((m) {
              if (m.id == aiMessageId) {
                return ChatMessage(
                  id: aiMessageId,
                  text: accumulatedText.toString(),
                  isUser: false,
                  timestamp: m.timestamp,
                );
              }
              return m;
            }).toList();
            return session.copyWith(messages: updatedMsgs);
          }
          return session;
        }).toList();

        state = state.copyWith(sessions: streamingSessions);
      }
      
      state = state.copyWith(isTyping: false);
    } on ApiException catch (e) {
      state = state.copyWith(isTyping: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isTyping: false, errorMessage: 'Failed to establish server connection.');
    }
  }

  Future<void> regenerateLastResponse() async {
    final session = state.activeSession;
    final lastUserMsgIdx = session.messages.lastIndexWhere((m) => m.isUser);
    if (lastUserMsgIdx == -1) return;

    final lastUserText = session.messages[lastUserMsgIdx].text;
    await sendMessage(lastUserText);
  }
}

final aiCoachProvider = StateNotifierProvider<AiCoachNotifier, AiCoachState>((ref) {
  return AiCoachNotifier();
});
