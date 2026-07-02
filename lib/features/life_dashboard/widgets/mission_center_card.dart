import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/mock_data.dart';

class MissionCenterCard extends ConsumerWidget {
  const MissionCenterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = kAllBooks.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Mission Center', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/home'),
                child: Text('See All', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...missions.map((book) => _MissionRow(book: book)),
        ],
      ),
    );
  }
}

class _MissionRow extends StatefulWidget {
  const _MissionRow({required this.book});
  final dynamic book;

  @override
  State<_MissionRow> createState() => _MissionRowState();
}

class _MissionRowState extends State<_MissionRow> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final progress = book.totalPages > 0 ? (book.readPages / book.totalPages).clamp(0.0, 1.0) : 0.0;
    final difficulty = book.totalPages < 250 ? 'Beginner' : book.totalPages < 400 ? 'Intermediate' : 'Advanced';
    final diffColor = book.totalPages < 250 ? const Color(0xFF82E2A0) : book.totalPages < 400 ? const Color(0xFFFFBE0B) : const Color(0xFFE26EBD);
    final xpReward = (book.totalPages * 12).toInt();
    final estHours = (book.totalPages / 40.0).toStringAsFixed(1);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => context.push('/book/${book.id}', extra: book),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: book.coverColors),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text(book.coverEmoji, style: const TextStyle(fontSize: 16))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: diffColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: diffColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(difficulty, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: diffColor)),
                                ),
                                const SizedBox(width: 6),
                                Text('⚡ $xpReward XP  ⏱️ ${estHours}h', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text('${(progress * 100).round()}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: progress > 0.5 ? AppColors.gold : AppColors.textTertiaryDark)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        Container(height: 4, color: AppColors.darkBorder),
                        FractionallySizedBox(
                          widthFactor: progress * _anim.value,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: book.coverColors),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Skills: ${(book.skillsUnlocked as List).take(2).join(', ')}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
