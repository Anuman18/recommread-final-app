import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/book_model.dart';
import 'book_card.dart';
import 'section_header.dart';

class RecentlyViewedSection extends StatefulWidget {
  const RecentlyViewedSection({super.key, required this.books});
  final List<Book> books;

  @override
  State<RecentlyViewedSection> createState() => _RecentlyViewedSectionState();
}

class _RecentlyViewedSectionState extends State<RecentlyViewedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _anims = List.generate(widget.books.length, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            i * 0.12,
            (i * 0.12 + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    Future.delayed(
      const Duration(milliseconds: 250),
      () { if (mounted) _ctrl.forward(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Briefings',
          onSeeAll: () {},
        ),
        SizedBox(
          height: 215,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            scrollDirection: Axis.horizontal,
            itemCount: widget.books.length,
            itemBuilder: (context, i) {
              return AnimatedBuilder(
                animation: _anims[i],
                builder: (_, child) => Opacity(
                  opacity: _anims[i].value,
                  child: Transform.translate(
                    offset: Offset(20 * (1 - _anims[i].value), 0),
                    child: child,
                  ),
                ),
                child: SmallBookCard(
                  book: widget.books[i],
                  onTap: () => context.push(
                    '/book/${widget.books[i].id}',
                    extra: widget.books[i],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
