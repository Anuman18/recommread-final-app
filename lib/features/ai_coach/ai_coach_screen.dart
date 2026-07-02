import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'ai_coach_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_history_drawer.dart';
import 'widgets/suggested_prompts.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _msgController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {}); // Repaint to toggle send button opacity/glow
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _handleSend() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    _focusNode.unfocus();
    HapticFeedback.lightImpact();

    await ref.read(aiCoachProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _handlePromptSelected(String promptText) async {
    HapticFeedback.lightImpact();
    await ref.read(aiCoachProvider.notifier).sendMessage(promptText);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiCoachProvider);
    final activeSession = state.activeSession;
    final messages = activeSession.messages;

    // Listen to changes to auto scroll when new messages arrive
    ref.listen<AiCoachState>(aiCoachProvider, (prev, next) {
      if (prev?.activeSession.messages.length != next.activeSession.messages.length ||
          prev?.isTyping != next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.darkBg,
      drawer: const ChatHistoryDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Custom AppBar ──────────────────────────────────────────────
              _buildAppBar(activeSession.title),

              // ── Messages View ──────────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: messages.isEmpty
                          ? _buildEmptyPromptView()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                              physics: const BouncingScrollPhysics(),
                              itemCount: messages.length + (state.isTyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == messages.length && state.isTyping) {
                                  return const TypingIndicator();
                                }
                                final msg = messages[index];
                                final isLastAi = !msg.isUser && index == messages.length - 1;

                                return ChatBubble(
                                  key: ValueKey(msg.id),
                                  message: msg,
                                  isLastAiMessage: isLastAi,
                                  onRegenerate: () {
                                    HapticFeedback.mediumImpact();
                                    ref.read(aiCoachProvider.notifier).regenerateLastResponse();
                                  },
                                );
                              },
                            ),
                    ),
                    
                    // Suggested Prompts (Horizontal Actions Row)
                    SuggestedPrompts(
                      onPromptSelected: _handlePromptSelected,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // ── Input Bar Section ──────────────────────────────────────────
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Drawer trigger
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.gold),
            onPressed: () {
              HapticFeedback.lightImpact();
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          const SizedBox(width: 8),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mentor AI',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // New chat shortcut
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.gold, size: 20),
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(aiCoachProvider.notifier).startNewChat();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.darkSurface,
                  content: Text(
                    'New mentoring session started 🚀',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPromptView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Identity Transformation Mentor',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Quiz your knowledge, get mission briefings, challenge yourself, or ask for your next growth mission.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final hasText = _msgController.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Input field container
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.darkBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.darkBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimaryDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask your mentor anything...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textTertiaryDark,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      cursorColor: AppColors.gold,
                    ),
                  ),
                  if (_msgController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _msgController.clear();
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send Button
          _SendButton(
            onPressed: hasText ? _handleSend : null,
            isActive: hasText,
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  const _SendButton({
    required this.onPressed,
    required this.isActive,
  });

  final VoidCallback? onPressed;
  final bool isActive;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.isActive) _pressCtrl.reverse();
      },
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _pressCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: widget.isActive ? AppColors.goldGradient : null,
            color: widget.isActive ? null : AppColors.darkBg,
            shape: BoxShape.circle,
            border: widget.isActive
                ? null
                : Border.all(color: AppColors.darkBorder),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.send_rounded,
            size: 16,
            color: widget.isActive ? AppColors.darkBg : AppColors.textTertiaryDark,
          ),
        ),
      ),
    );
  }
}
