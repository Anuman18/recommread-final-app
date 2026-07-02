import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../life_dashboard_provider.dart';

class DailyAgendaCard extends ConsumerWidget {
  const DailyAgendaCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeDashboardProvider);
    final agenda = state.agenda;
    final done = agenda.where((a) => a.completed).length;
    final progress = agenda.isEmpty ? 0.0 : done / agenda.length;

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
              const Text('📋', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Daily Agenda', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Text('$done / ${agenda.length}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 4, color: AppColors.darkElevated),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 4,
                    decoration: const BoxDecoration(gradient: AppColors.goldGradient),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...agenda.map((item) => _AgendaRow(item: item, onTap: () {
            HapticFeedback.selectionClick();
            ref.read(lifeDashboardProvider.notifier).toggleAgendaItem(item.id);
          })),
        ],
      ),
    );
  }
}

class _AgendaRow extends StatefulWidget {
  const _AgendaRow({required this.item, required this.onTap});
  final AgendaItem item;
  final VoidCallback onTap;

  @override
  State<_AgendaRow> createState() => _AgendaRowState();
}

class _AgendaRowState extends State<_AgendaRow> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.item.completed;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: done ? AppColors.goldGradient : null,
                  color: done ? null : AppColors.darkElevated,
                  border: done ? null : Border.all(color: AppColors.darkBorder),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.black87)
                      : Text(widget.item.icon, style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: done ? AppColors.textTertiaryDark : AppColors.textPrimaryDark,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(widget.item.subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('+${widget.item.xpReward}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
