import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../ai_coach_provider.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isLastAiMessage,
    required this.onRegenerate,
  });

  final ChatMessage message;
  final bool isLastAiMessage;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAiAvatar(),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Bubble container
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.95 + (value * 0.05),
                        alignment:
                            isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.gold : AppColors.darkSurface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isUser
                            ? const Radius.circular(20)
                            : const Radius.circular(4),
                        bottomRight: isUser
                            ? const Radius.circular(4)
                            : const Radius.circular(20),
                      ),
                      border: isUser
                          ? null
                          : Border.all(color: AppColors.darkBorder, width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isUser ? 0.15 : 0.05,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: _buildMessageContent(context),
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(height: 6),
                  _buildMessageActions(context),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 16,
          color: AppColors.darkBg,
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Center(
        child: Text(
          'AR',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }

  // Premium Custom Markdown Renders (Lists, Bold, Items)
  Widget _buildMessageContent(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 14,
      color: message.isUser ? AppColors.darkBg : AppColors.textPrimaryDark,
      height: 1.6,
      fontWeight: message.isUser ? FontWeight.w600 : FontWeight.w500,
    );

    if (message.isUser) {
      return Text(message.text, style: style);
    }

    final lines = message.text.split('\n');
    final List<Widget> children = [];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 10));
        continue;
      }

      // Bullet Point check
      if (line.trim().startsWith('* ') || line.trim().startsWith('- ')) {
        final cleanText = line.trim().substring(2);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseBoldText(cleanText, style),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Numbered List check
      else if (RegExp(r'^\d+\.\s').hasMatch(line.trim())) {
        final match = RegExp(r'^(\d+\.)\s(.*)').firstMatch(line.trim());
        if (match != null) {
          final number = match.group(1)!;
          final cleanText = match.group(2)!;
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: style.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: _parseBoldText(cleanText, style),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
      // Standard line
      else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: RichText(
              text: TextSpan(
                children: _parseBoldText(line, style),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  // Renders Markdown Bold text correctly
  List<TextSpan> _parseBoldText(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      final isBold = i % 2 == 1;
      spans.add(
        TextSpan(
          text: parts[i],
          style: isBold
              ? baseStyle.copyWith(
                  fontWeight: FontWeight.w800,
                  color: message.isUser ? AppColors.darkBg : AppColors.gold,
                )
              : baseStyle,
        ),
      );
    }
    return spans;
  }

  Widget _buildMessageActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          // Copy button
          _ActionButton(
            icon: Icons.copy_all_rounded,
            tooltip: 'Copy',
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.text));
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.darkSurface,
                  content: Text(
                    'Response copied to clipboard',
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
          const SizedBox(width: 8),
          // Regenerate button
          if (isLastAiMessage) ...[
            _ActionButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Regenerate',
              onTap: onRegenerate,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      textStyle: GoogleFonts.inter(color: AppColors.darkBg, fontSize: 11, fontWeight: FontWeight.w700),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 15,
            color: AppColors.textTertiaryDark,
          ),
        ),
      ),
    );
  }
}

// ── Typing Indicator Widget ───────────────────────────────────────────────

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.darkBg,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: AppColors.darkBorder, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final double delay = i * 0.2;
                    final double val = sin((_controller.value * 2 * pi) - delay);
                    final double offset = (val + 1.0) / 2.0 * 6.0;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      transform: Matrix4.translationValues(0, -offset, 0),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
