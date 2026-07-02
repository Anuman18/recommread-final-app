import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'projects_provider.dart';

class ProjectMentorChatScreen extends ConsumerStatefulWidget {
  const ProjectMentorChatScreen({super.key, required this.project});
  final Project project;

  @override
  ConsumerState<ProjectMentorChatScreen> createState() => _ProjectMentorChatScreenState();
}

class _ProjectMentorChatScreenState extends ConsumerState<ProjectMentorChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _msgCtrl.clear();
    HapticFeedback.lightImpact();
    
    final notifier = ref.read(projectsProvider.notifier);
    await notifier.sendMentorMessage(widget.project.id, text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectsProvider);
    final chats = state.projectMentorChats[widget.project.id] ?? [];

    // Trigger auto-scroll when new message arrives or loading state changes
    _scrollToBottom();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Project Mentor',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark),
            ),
            Text(
              widget.project.name,
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'ONLINE',
                  style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.gold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: Column(
          children: [
            // Chat history list
            Expanded(
              child: chats.isEmpty
                  ? const _EmptyChatPlaceholder()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: chats.length,
                      itemBuilder: (context, i) {
                        final msg = chats[i];
                        final isUser = msg.sender == 'user';
                        return _ChatBubble(message: msg, isUser: isUser);
                      },
                    ),
            ),

            // Suggested prompt actions (floating above the text field)
            if (!state.isSendingMessage) _buildQuickPrompts(),

            // Typing loader
            if (state.isSendingMessage)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Row(
                  children: [
                    Text('🤖 Mentor is analyzing...', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),

            // Bottom Input bar
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Quick prompt suggestions ──────────────────────────────────────────────

  Widget _buildQuickPrompts() {
    final prompts = [
      '💡 Give me a hint',
      '🎯 What is my next step?',
      '🛠️ Review my setup code',
    ];
    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final pText = prompts[i];
          return GestureDetector(
            onTap: () => _sendMessage(pText.substring(2)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Text(
                pText,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondaryDark),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bottom input panel ─────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        border: Border(top: BorderSide(color: AppColors.darkBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: TextField(
                  controller: _msgCtrl,
                  onSubmitted: _sendMessage,
                  style: GoogleFonts.inter(color: AppColors.textPrimaryDark, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Ask mentor for review, hints, or questions...',
                    hintStyle: GoogleFonts.inter(color: AppColors.textTertiaryDark, fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_msgCtrl.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.send_rounded, size: 16, color: AppColors.darkBg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Bubble sub-widget ───────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isUser});
  final MentorMessage message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Text('🤖', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.darkElevated : AppColors.darkCard,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                  ),
                  border: Border.all(
                    color: isUser ? AppColors.gold.withValues(alpha: 0.25) : AppColors.darkBorder,
                  ),
                ),
                child: Text(
                  message.text,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isUser ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              const Text('👤', style: TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  const _EmptyChatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Your Personal AI Mentor',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Start chatting to review your code setup, request custom explanations, or ask for guidance on any milestone.',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
