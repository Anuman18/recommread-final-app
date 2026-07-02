import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/book_model.dart';
import 'book_card.dart';
import 'section_header.dart';

class TrendingSection extends StatefulWidget {
  const TrendingSection({super.key, required this.books});
  final List<Book> books;

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardAnims = List.generate(widget.books.length, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            i * 0.1,
            (i * 0.1 + 0.55).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    Future.delayed(
      const Duration(milliseconds: 300),
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
          title: '🔥 Popular Missions',
          subtitle: 'Missions with highest completion rate',
          onSeeAll: () {},
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: widget.books.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: AnimatedBuilder(
                  animation: _cardAnims[i],
                  builder: (_, child) => Opacity(
                    opacity: _cardAnims[i].value,
                    child: Transform.translate(
                      offset: Offset(30 * (1 - _cardAnims[i].value), 0),
                      child: child,
                    ),
                  ),
                  child: BookCard(
                    book: widget.books[i],
                    showRank: i + 1,
                    onTap: () => context.push(
                      '/book/${widget.books[i].id}',
                      extra: widget.books[i],
                    ),
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
