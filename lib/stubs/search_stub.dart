import 'package:flutter/material.dart';
import '../navigation/main_shell.dart';

class SearchStub extends StatelessWidget {
  const SearchStub({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonStub(
        title: 'Search',
        emoji: '🔍',
        subtitle: 'Find your next great book\nfrom millions of titles.',
        gradientColors: [Color(0xFF006064), Color(0xFF004D40)],
      );
}
