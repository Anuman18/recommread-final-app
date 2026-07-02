import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../ai_coach_provider.dart';

class ChatHistoryDrawer extends ConsumerWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiCoachProvider);
    final sessions = state.sessions;

    return Drawer(
      backgroundColor: AppColors.darkBg,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: AppColors.darkBorder, width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Section ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: AppColors.gold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Coaching History',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // New Chat Button
                    AnimatedButton(
                      height: 48,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(aiCoachProvider.notifier).startNewChat();
                        Navigator.pop(context); // Close drawer
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            color: AppColors.darkBg,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'New Coaching Chat',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: AppColors.darkBorder),
              ),

              // ── Sessions List ──────────────────────────────────────────────
              Expanded(
                child: sessions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final isActive = session.id == state.activeSessionId;

                          return Padding(
                            key: ValueKey(session.id),
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _SessionTile(
                              session: session,
                              isActive: isActive,
                              onTap: () {
                                ref.read(aiCoachProvider.notifier).selectSession(session.id);
                                Navigator.pop(context);
                              },
                              onDelete: () {
                                ref.read(aiCoachProvider.notifier).deleteSession(session.id);
                              },
                            ),
                          );
                        },
                      ),
              ),

              // ── Footer ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'RecommRead AI Coach v1.0',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textTertiaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.forum_outlined,
              size: 32,
              color: AppColors.textTertiaryDark,
            ),
            const SizedBox(height: 12),
            Text(
              'No previous chats',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatefulWidget {
  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  final ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<_SessionTile> {
  bool _isHovering = false;

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final String minute = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
      final String hour = dt.hour > 12
          ? '${dt.hour - 12}'
          : dt.hour == 0
              ? '12'
              : '${dt.hour}';
      final String ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $ampm';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppColors.gold.withValues(alpha: 0.1)
              : _isHovering
                  ? AppColors.darkSurface.withValues(alpha: 0.5)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: widget.isActive
              ? Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 0.5)
              : Border.all(color: Colors.transparent, width: 0.5),
        ),
        child: ListTile(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Icon(
            widget.isActive
                ? Icons.auto_awesome_rounded
                : Icons.chat_bubble_outline_rounded,
            size: 16,
            color: widget.isActive ? AppColors.gold : AppColors.textSecondaryDark,
          ),
          title: Text(
            widget.session.title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.w600,
              color: widget.isActive ? AppColors.gold : AppColors.textPrimaryDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatTime(widget.session.updatedAt),
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textTertiaryDark,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
            color: AppColors.textTertiaryDark,
            onPressed: () {
              // Confirm dialog or directly delete with undo option
              HapticFeedback.mediumImpact();
              widget.onDelete();
            },
          ),
        ),
      ),
    );
  }
}
