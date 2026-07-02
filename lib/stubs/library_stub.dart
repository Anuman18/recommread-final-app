import 'package:flutter/material.dart';
import '../navigation/main_shell.dart';

class LibraryStub extends StatelessWidget {
  const LibraryStub({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonStub(
        title: 'My Library',
        emoji: '📚',
        subtitle: 'All your books in one place.\nTrack your reading journey.',
        gradientColors: [Color(0xFF1A237E), Color(0xFF283593)],
      );
}
