import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';

// ── Chat Message Model ─────────────────────────────────────────────────────

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

// ── Chat Session Model (History) ───────────────────────────────────────────

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

// ── AI Coach State Model ───────────────────────────────────────────────────

class AiCoachState {
  final List<ChatSession> sessions;
  final String activeSessionId;
  final bool isTyping;

  AiCoachState({
    required this.sessions,
    required this.activeSessionId,
    this.isTyping = false,
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
  }) {
    return AiCoachState(
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

// ── AI Coach State Notifier ────────────────────────────────────────────────

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  AiCoachNotifier()
      : super(AiCoachState(
          sessions: [],
          activeSessionId: 'session_1',
        )) {
    _initSessions();
  }

  void _initSessions() {
    final now = DateTime.now();
    final firstSession = ChatSession(
      id: 'session_1',
      title: '🚀 Identity Transformation – Session 1',
      messages: [
        ChatMessage(
          id: 'm1',
          text: 'Welcome, Operator. I am your **Identity Transformation Mentor**. I\u2019ve analysed your target identity and current mission progress.\n\nUse the action cues below to **quiz yourself**, get a **mission briefing**, or ask me to **challenge you** with real-world tasks. Your transformation starts now. 🎯',
          isUser: false,
          timestamp: now.subtract(const Duration(minutes: 10)),
        ),
      ],
      updatedAt: now,
    );

    final secondSession = ChatSession(
      id: 'session_2',
      title: '🧠 Deep Work – Cognitive Intensity Briefing',
      messages: [
        ChatMessage(
          id: 'm2',
          text: 'Explain Cal Newport\'s concept of high-intensity deep focus.',
          isUser: true,
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: 'm3',
          text: 'Newport argues that **High-Quality Work Produced = (Time Spent) x (Intensity of Focus)**. To produce at your peak, you must work for extended periods with zero distractions.',
          isUser: false,
          timestamp: now.subtract(const Duration(hours: 2, minutes: 1)),
        ),
      ],
      updatedAt: now.subtract(const Duration(hours: 2)),
    );

    state = AiCoachState(
      sessions: [firstSession, secondSession],
      activeSessionId: 'session_1',
    );
  }

  void startNewChat() {
    final now = DateTime.now();
    final newSessionId = 'session_${now.millisecondsSinceEpoch}';
    final newSession = ChatSession(
      id: newSessionId,
      title: '💬 New Coaching Chat',
      messages: [
        ChatMessage(
          id: 'welcome',
          text: 'New mentoring session started. What would you like to work on? Choose an action cue below or type your own question. 🚀',
          isUser: false,
          timestamp: now,
        ),
      ],
      updatedAt: now,
    );

    state = state.copyWith(
      sessions: [newSession, ...state.sessions],
      activeSessionId: newSessionId,
    );
  }

  void selectSession(String sessionId) {
    state = state.copyWith(activeSessionId: sessionId);
  }

  void deleteSession(String sessionId) {
    final filtered = state.sessions.where((s) => s.id != sessionId).toList();
    
    // If we deleted the active one, pick the first remaining or make a new one
    String activeId = state.activeSessionId;
    if (activeId == sessionId) {
      if (filtered.isNotEmpty) {
        activeId = filtered.first.id;
      } else {
        // Automatically start new chat if list is empty
        state = state.copyWith(sessions: filtered);
        startNewChat();
        return;
      }
    }

    state = state.copyWith(
      sessions: filtered,
      activeSessionId: activeId,
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Update active session with user message
    final updatedSessions = state.sessions.map((session) {
      if (session.id == state.activeSessionId) {
        String title = session.title;
        if (title == 'New Coaching Chat') {
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

    state = state.copyWith(
      sessions: updatedSessions,
      isTyping: true,
    );

    String responseText = '';
    try {
      final responseMap = await apiClient.post('/ai-coach/chat', body: {
        'message': text,
      });
      responseText = responseMap['response'] ?? 'I am having trouble processing that right now.';
    } catch (e) {
      responseText = 'Error connecting to AI Coach service. Please try again.';
    }

    final aiMessage = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}_ai',
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    final finalSessions = state.sessions.map((session) {
      if (session.id == state.activeSessionId) {
        return session.copyWith(
          messages: [...session.messages, aiMessage],
          updatedAt: DateTime.now(),
        );
      }
      return session;
    }).toList();

    state = state.copyWith(
      sessions: finalSessions,
      isTyping: false,
    );
  }

  // Regenerate last AI response
  Future<void> regenerateLastResponse() async {
    final session = state.activeSession;
    if (session.messages.isEmpty) return;
    
    final lastUserMsgIdx = session.messages.lastIndexWhere((m) => m.isUser);
    if (lastUserMsgIdx == -1) return;

    final lastUserText = session.messages[lastUserMsgIdx].text;
    final trimmedMessages = session.messages.sublist(0, lastUserMsgIdx + 1);

    final updatedSessions = state.sessions.map((s) {
      if (s.id == state.activeSessionId) {
        return s.copyWith(messages: trimmedMessages, updatedAt: DateTime.now());
      }
      return s;
    }).toList();

    state = state.copyWith(
      sessions: updatedSessions,
      isTyping: true,
    );

    String responseText = '';
    try {
      final responseMap = await apiClient.post('/ai-coach/chat', body: {
        'message': lastUserText,
      });
      responseText = '${responseMap['response'] ?? 'I am having trouble processing that right now.'}\n*(Regenerated response)*';
    } catch (e) {
      responseText = 'Error connecting to AI Coach service. Please try again.';
    }

    final aiMessage = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}_ai_regen',
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    final finalSessions = state.sessions.map((s) {
      if (s.id == state.activeSessionId) {
        return s.copyWith(
          messages: [...s.messages, aiMessage],
          updatedAt: DateTime.now(),
        );
      }
      return s;
    }).toList();

    state = state.copyWith(
      sessions: finalSessions,
      isTyping: false,
    );
  }


}

final aiCoachProvider = StateNotifierProvider<AiCoachNotifier, AiCoachState>((ref) {
  return AiCoachNotifier();
});
