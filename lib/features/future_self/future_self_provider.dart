import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MilestoneType { levelUp, missionComplete, skillUnlocked, streak7, streak30, xp1000 }

class Milestone {
  final MilestoneType type;
  final String title;
  final String subtitle;
  final String emoji;
  final int xpGained;
  const Milestone({required this.type, required this.title, required this.subtitle, required this.emoji, this.xpGained = 0});
}

class MentorMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  MentorMessage({required this.id, required this.text, required this.isUser, required this.timestamp});
}

class FutureSelfState {
  final List<MentorMessage> messages;
  final bool isTyping;
  final bool introSeen;
  final Milestone? pendingMilestone;
  const FutureSelfState({this.messages = const [], this.isTyping = false, this.introSeen = false, this.pendingMilestone});
  FutureSelfState copyWith({List<MentorMessage>? messages, bool? isTyping, bool? introSeen, Milestone? pendingMilestone, bool clearMilestone = false}) {
    return FutureSelfState(messages: messages ?? this.messages, isTyping: isTyping ?? this.isTyping, introSeen: introSeen ?? this.introSeen, pendingMilestone: clearMilestone ? null : (pendingMilestone ?? this.pendingMilestone));
  }
}

class FutureSelfNotifier extends StateNotifier<FutureSelfState> {
  FutureSelfNotifier() : super(const FutureSelfState()) { _checkIntroSeen(); }

  Future<void> _checkIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool("future_self_intro_seen") ?? false;
    if (seen && mounted) state = state.copyWith(introSeen: true);
  }

  Future<void> markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("future_self_intro_seen", true);
    state = state.copyWith(introSeen: true);
  }

  List<String> generateIntroLines(String name, String goalLabel, int level, int xp) {
    return [
      "Hi $name.",
      "I'm the version of you — 5 years from now.",
      "You became a $goalLabel.",
      "And you achieved it because you stayed consistent.",
      "Right now you are at Level $level with $xp XP.",
      "You still have a long journey ahead.",
      "But I am here to guide you.",
      "Every mission you complete gets you closer to me.",
      "Let's begin your transformation.",
    ];
  }

  Future<void> sendMessage(String userText, String goalLabel, int level, int xp) async {
    final userMsg = MentorMessage(id: "m_user_${DateTime.now().millisecondsSinceEpoch}", text: userText, isUser: true, timestamp: DateTime.now());
    state = state.copyWith(messages: [...state.messages, userMsg], isTyping: true);
    await Future.delayed(const Duration(milliseconds: 1800));
    final response = _generateResponse(userText.toLowerCase(), goalLabel, level, xp);
    final aiMsg = MentorMessage(id: "m_ai_${DateTime.now().millisecondsSinceEpoch}", text: response, isUser: false, timestamp: DateTime.now());
    state = state.copyWith(messages: [...state.messages, aiMsg], isTyping: false);
  }

  String _generateResponse(String prompt, String goalLabel, int level, int xp) {
    if (prompt.contains("advice") || prompt.contains("tip") || prompt.contains("help")) {
      return "From where I stand, the single most important thing you can do right now is show up every day. Consistency compounds. At Level $level, your foundation is still forming — protect it fiercely.";
    } else if (prompt.contains("today") || prompt.contains("mission") || prompt.contains("next")) {
      return "Your next mission is the bridge between who you are and who I am. Focus on completing one full chapter today. Small win. Massive impact over time.";
    } else if (prompt.contains("skill") || prompt.contains("learn") || prompt.contains("grow")) {
      return "To become a $goalLabel, the skills that matter most are Communication, Critical Thinking, and Productivity. Each mission you complete raises these. Your radar is already shifting.";
    } else if (prompt.contains("why") || prompt.contains("matter") || prompt.contains("important")) {
      return "You are $xp XP into a journey that most people never start. The fact that you are here — asking questions — already separates you. Every mission matters because attention is compounding.";
    } else if (prompt.contains("skip") || prompt.contains("fail") || prompt.contains("miss")) {
      return "I know some days feel impossible. But I am living proof that you can make it through. The only way I became a $goalLabel was because past-you refused to give up. One page is better than zero.";
    } else if (prompt.contains("proud") || prompt.contains("done") || prompt.contains("complete")) {
      return "You made me possible. Every mission you complete adds another tile to the mosaic of who I am. I am proud of you — and trust me, that is a strange thing to say about yourself.";
    } else if (prompt.contains("roadmap") || prompt.contains("plan") || prompt.contains("path")) {
      return "Your roadmap is designed to build you layer by layer: first habits, then knowledge, then execution, then mastery. You are in Phase 1 right now — the most important phase.";
    } else {
      return "I hear you. From where I am — on the other side of the work you are doing — I can tell you: this moment matters. The questions you are asking today shaped the answers I now live. Keep pushing forward.";
    }
  }

  void initConversation(String name, String goalLabel, int level, int xp) {
    if (state.messages.isNotEmpty) return;
    final greeting = MentorMessage(id: "m_greeting", text: "Good to see you again, $name. I am your Future Self — the $goalLabel version of you. You are at Level $level with $xp XP. Ask me anything about your journey, your next mission, or why any of this matters.", isUser: false, timestamp: DateTime.now());
    state = state.copyWith(messages: [greeting]);
  }

  void triggerMilestone(Milestone milestone) { state = state.copyWith(pendingMilestone: milestone); }
  void clearMilestone() { state = state.copyWith(clearMilestone: true); }
}

final futureSelfProvider = StateNotifierProvider<FutureSelfNotifier, FutureSelfState>((ref) => FutureSelfNotifier());

const kLevelUpMilestone = Milestone(type: MilestoneType.levelUp, title: "Level Up!", subtitle: "You have ascended to a new level of mastery.", emoji: "⚡");
const kMissionCompleteMilestone = Milestone(type: MilestoneType.missionComplete, title: "Mission Complete", subtitle: "You finished a mission and unlocked new skills.", emoji: "🏆", xpGained: 2400);
const kSkillUnlockedMilestone = Milestone(type: MilestoneType.skillUnlocked, title: "Skill Unlocked", subtitle: "A new attribute has crossed the threshold.", emoji: "🧠", xpGained: 500);
const kStreak7Milestone = Milestone(type: MilestoneType.streak7, title: "7-Day Streak", subtitle: "Seven consecutive days of transformation.", emoji: "🔥", xpGained: 700);
const kStreak30Milestone = Milestone(type: MilestoneType.streak30, title: "30-Day Streak", subtitle: "A full month of relentless growth.", emoji: "💎", xpGained: 3000);
const kXp1000Milestone = Milestone(type: MilestoneType.xp1000, title: "1000 XP Earned", subtitle: "The first thousand steps of your identity shift.", emoji: "🌟", xpGained: 1000);
