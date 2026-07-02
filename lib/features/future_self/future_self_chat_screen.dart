import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding/onboarding_provider.dart';
import '../profile/xp_provider.dart';
import '../profile/profile_provider.dart';
import 'future_self_provider.dart';

class FutureSelfChatScreen extends ConsumerStatefulWidget {
  const FutureSelfChatScreen({super.key});

  @override
  ConsumerState<FutureSelfChatScreen> createState() => _FutureSelfChatScreenState();
}

class _FutureSelfChatScreenState extends ConsumerState<FutureSelfChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  static const _quickPrompts = [
    'Give me advice for today',
    'What should my next mission be?',
    'Why does any of this matter?',
    'Help me stay consistent',
    'Tell me about my skill growth',
    "I'm feeling like giving up",
    'What\'s my growth roadmap?',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());
  }

  void _initChat() {
    final profileState = ref.read(profileProvider);
    final xpState = ref.read(xpProvider);
    final onboardingState = ref.read(onboardingProvider);
    final goalLabel = onboardingState.goal?.label ?? profileState.readingGoal.label;
    ref.read(futureSelfProvider.notifier).initConversation(
      profileState.name,
      goalLabel,
      xpState.level,
      xpState.currentXp,
    );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    _focusNode.unfocus();
    HapticFeedback.lightImpact();

    final profileState = ref.read(profileProvider);
    final xpState = ref.read(xpProvider);
    final onboardingState = ref.read(onboardingProvider);
    final goalLabel = onboardingState.goal?.label ?? profileState.readingGoal.label;

    await ref.read(futureSelfProvider.notifier).sendMessage(
      text,
      goalLabel,
      xpState.level,
      xpState.currentXp,
    );
    _scrollToBottom();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(futureSelfProvider);

    ref.listen<FutureSelfState>(futureSelfProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length || prev?.isTyping != next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: state.messages.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                              itemBuilder: (context, i) {
                                if (i == state.messages.length && state.isTyping) {
                                  return _buildTypingIndicator();
                                }
                                return _buildBubble(state.messages[i]);
                              },
                            ),
                    ),
                    _buildQuickPrompts(),
                    _buildInputBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.darkBorder, width: 0.5))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.darkBorder)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textPrimaryDark),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient),
            child: const Center(child: Text('✨', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Future Self', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
              Text('5 years from now', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4ECDC4))),
                const SizedBox(width: 5),
                Text('Online', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF4ECDC4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(MentorMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient),
              child: const Center(child: Text('✨', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.gold : AppColors.darkCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser ? null : Border.all(color: AppColors.darkBorder, width: 0.5),
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isUser ? AppColors.darkBg : AppColors.textPrimaryDark,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient),
            child: const Center(child: Text('✨', style: TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
              border: Border.all(color: AppColors.darkBorder, width: 0.5),
            ),
            child: Row(
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(200),
                const SizedBox(width: 4),
                _dot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, val, _) => Opacity(
        opacity: val,
        child: Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold)),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _quickPrompts.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => _sendMessage(_quickPrompts[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder, width: 0.5),
              ),
              child: Text(_quickPrompts[i], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryDark)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    final hasText = _ctrl.text.trim().isNotEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(color: AppColors.darkSurface, border: Border(top: BorderSide(color: AppColors.darkBorder, width: 0.5))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: AppColors.darkBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.darkBorder)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(_ctrl.text),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'Ask your future self anything...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiaryDark),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                cursorColor: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: hasText ? () => _sendMessage(_ctrl.text) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: hasText ? AppColors.goldGradient : null,
                color: hasText ? null : AppColors.darkBg,
                shape: BoxShape.circle,
                border: hasText ? null : Border.all(color: AppColors.darkBorder),
                boxShadow: hasText ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
              ),
              child: Icon(Icons.send_rounded, size: 16, color: hasText ? AppColors.darkBg : AppColors.textTertiaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient, boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 20)]),
            child: const Center(child: Text('✨', style: TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 16),
          Text('Your Future Self is ready', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
          const SizedBox(height: 8),
          Text('Ask anything about your transformation journey', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }
}
